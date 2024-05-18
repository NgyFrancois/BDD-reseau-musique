/* requete qui permet de récupérer le nom du lieu et le nom du groupe organisateur pour chaque concert :
trois tables*/
DEALLOCATE ALL;
DROP VIEW IF EXISTS vue_recommandation_concerts cascade;

PREPARE recherche_concerts AS
SELECT DISTINCT Concerts.nom AS nom_concert, Lieu.adresse AS adresse_lieu, Utilisateurs.nom AS nom_groupe
FROM Concerts
JOIN Lieu ON Concerts.adresse = Lieu.adresse
JOIN Organise ON Concerts.id_concert = Organise.id_concert
JOIN Groupes ON Organise.id_groupe = Groupes.id_groupe
JOIN Utilisateurs ON Groupes.id_groupe = Utilisateurs.id
;

/* recherche amis d'un utilisateur(ex:Shandee) inner join*/

PREPARE recherche_amis(VARCHAR(100), VARCHAR(100)) AS
SELECT u.nom as ami
FROM Utilisateurs u
INNER JOIN Follows f1 ON u.id = f1.id_suivi
INNER JOIN Follows f2 ON u.id = f2.id_suiveur
WHERE f1.id_suiveur=(SELECT id FROM Utilisateurs WHERE email=$2 AND nom=$1)
  AND f2.id_suivi=(SELECT id FROM Utilisateurs WHERE email=$2 AND nom=$1)
;

/* concerts qui ont plus de n participants
corrélée*/
PREPARE recherche_concerts_participants(INTEGER) AS
SELECT id_concert, nom
FROM Concerts c
WHERE (SELECT COUNT(*)
  FROM Participants p
  WHERE p.id_concert = c.id_concert) > $1;

/*nombre de concerts auxquels chaque utilisateur a participé
ss-requête dans FROM */
PREPARE recherche_nb_concerts AS
SELECT T.nom, COUNT(*) AS nb_concerts
FROM (
  SELECT DISTINCT P.id_personne, C.id_concert
  FROM Participants P
  INNER JOIN Concerts C ON P.id_concert = C.id_concert
) AS PC
INNER JOIN Personnes U ON U.id_personne = PC.id_personne
INNER JOIN Utilisateurs T ON T.id = U.id_personne
GROUP BY T.nom
ORDER BY nb_concerts DESC;

/* noms des utilisateurs qui suivent au moins deux autres utilisateurs
ss-requête dans WHERE */
PREPARE recherche_suiveurs AS
SELECT U.nom,U.email 
FROM Utilisateurs U
WHERE id IN (
  SELECT id_suiveur 
  FROM Follows 
  GROUP BY id_suiveur 
  HAVING COUNT(*) >= 2
);

/* recherches sous-genres de chaque genre
jointure externe */
PREPARE recherche_sous_genres AS
SELECT g.*, sg.nom_sous_genre 
FROM Genre g
LEFT JOIN Sous_genre sg ON g.nom_genre = sg.genre_parent
ORDER BY g.nom_genre;

/* nom de chaque utilisateur ayant participé à plus de cinq
concerts 
*/
PREPARE recherche_utilisateurs AS
SELECT
  U.nom,
  U.email,
  COUNT(*) AS nb_concerts,
  ROUND(AVG(CAST(C.prix AS DECIMAL)), 2) AS prix_moyen
FROM
Participants P
INNER JOIN Concerts C ON P.id_concert = C.id_concert
INNER JOIN Personnes Pe ON P.id_personne = Pe.id_personne
INNER JOIN Utilisateurs U ON U.id = Pe.id_personne
GROUP BY U.nom, U.email
HAVING COUNT(*) > 5 AND AVG(CAST(C.prix AS DECIMAL)) > 20.00
ORDER BY nb_concerts DESC;

/* LISTE DES GROUPES ayant une moyenne des notes des avis supérieure à 3.5
*/
PREPARE recherche_groupes AS
SELECT G.id_groupe, ROUND(AVG(A.note), 2) as moyenne_notes
FROM Avis_groupes AG
INNER JOIN Avis A ON AG.id_avis = A.id_avis
INNER JOIN Groupes G ON AG.id_groupe = G.id_groupe
GROUP BY G.id_groupe
HAVING AVG(A.note) > 3.5;

/* moyenne des notes maximales données par chaque utilisateur
*/
PREPARE recherche_moyenne_max_notes AS
SELECT ROUND(AVG(max_notes),2) AS moyenne_max_notes
FROM (
  SELECT id_utilisateur, MAX(note) AS max_notes
  FROM Avis
  GROUP BY id_utilisateur
) AS max_notes_utilisateur;

PREPARE recherche_concerts_populaires AS
WITH mois AS (
  SELECT 
    generate_series(
      DATE('2022-01-01'), 
      DATE('2022-12-31'), 
      INTERVAL '1 month'
    ) AS debut_mois,
    generate_series(
      DATE('2022-01-31'), 
      DATE('2022-12-31'), 
      INTERVAL '1 month'
    ) AS fin_mois
), 
interet_concert AS (
  SELECT 
    id_concert, 
    id_personne, 
    date_trunc('month', heuredate) AS mois 
  FROM 
    Participants 
    JOIN Concerts USING (id_concert)
), 
top_groupes AS (
  SELECT 
    id_groupe, 
    mois, 
    COUNT(id_personne) AS nb_interets, 
    RANK() OVER (
      PARTITION BY mois ORDER BY COUNT(id_personne) DESC
    ) AS classement 
  FROM 
    interet_concert 
    JOIN Organise USING (id_concert) 
  GROUP BY 
    id_groupe, 
    mois
)
SELECT 
  debut_mois, 
  fin_mois, 
  id_groupe, 
  nb_interets 
FROM 
  mois 
  JOIN top_groupes 
    ON mois.debut_mois <= top_groupes.mois 
    AND top_groupes.mois <= mois.fin_mois 
WHERE 
  classement <= 10
ORDER BY 
  debut_mois, 
  fin_mois, 
  nb_interets DESC;

DROP VIEW IF EXISTS vue_recommandation_concerts;
CREATE OR REPLACE VIEW vue_recommandation_concerts AS
SELECT c.id_concert,
    c.nom,
    l.ville,
    l.etat,
    TO_CHAR(DATE_TRUNC('day', c.heuredate), 'DD/MM/YYYY') AS dateconcert,
    COALESCE(ROUND((AVG(a.note) * 0.5 + 
                      COUNT(CASE WHEN p.id_personne IS NOT NULL THEN p.id_personne END) * 0.3 + 
                      COUNT(CASE WHEN i.id_personne IS NOT NULL THEN i.id_personne END) * 0.2)::numeric, 2),0) AS recommandation
FROM Concerts c
JOIN Organise o ON o.id_concert = c.id_concert
JOIN Lieu l ON l.adresse = c.adresse
JOIN Groupes g ON g.id_groupe = o.id_groupe
LEFT JOIN Participants p ON p.id_concert = c.id_concert
LEFT JOIN Interesses i ON i.id_concert = c.id_concert
LEFT JOIN Avis_groupes ag ON ag.id_groupe = g.id_groupe
LEFT JOIN Avis a ON a.id_avis = ag.id_avis
WHERE c.heuredate > CURRENT_DATE
  AND c.heuredate < CURRENT_DATE + INTERVAL '6 months'
GROUP BY c.id_concert, c.nom, l.ville, l.etat, c.heuredate
;

PREPARE recommandation_concerts_utilisateur(text, text, integer) AS
SELECT *
FROM vue_recommandation_concerts
WHERE (ville = (SELECT ville FROM Utilisateurs WHERE nom = $1 AND email = $2) 
  OR etat = (SELECT etat FROM Utilisateurs WHERE nom = $1 AND email = $2))
ORDER BY recommandation DESC
LIMIT $3;

-- Groupe le plus populaire ( le plus de concert)
PREPARE groupe_populaire AS
SELECT Utilisateurs.nom, COUNT(Organise.id_groupe) AS nombre_concerts
FROM Utilisateurs
INNER JOIN Groupes ON Utilisateurs.id = Groupes.id_groupe
INNER JOIN Organise ON Groupes.id_groupe = Organise.id_groupe
GROUP BY Utilisateurs.nom
ORDER BY nombre_concerts DESC
LIMIT 1;

-- Age moyen des utilisateurs 
PREPARE age_moyen AS
SELECT AVG(age) AS age_moyen FROM Utilisateurs;

-- Concert le mieux noté 
PREPARE conert_le_mieux_note AS
SELECT Concerts.nom, AVG(Avis.note) AS moyenne_notes
From Concerts
INNER JOIN Avis_concerts ON Concerts.id_concert = Avis_concerts.id_concert
INNER JOIN Avis ON Avis_concerts.id_avis = Avis.id_avis
GROUP BY Concerts.nom
ORDER BY moyenne_notes DESC
LIMIT 1;

-- Concert le plus célèbre ( le plus de participants ) 
PREPARE concert_le_plus_célèbre AS 
SELECT Concerts.nom, COUNT(Participants.id_personne) AS participants
FROM Concerts
INNER JOIN Participants ON Participants.id_concert = Concerts.id_concert
GROUP BY Concerts.nom
ORDER BY participants DESC
LIMIT 1;

-- Utilisateur le plus suivi 
PREPARE utilisateur_le_plus_suivi AS
SELECT Utilisateurs.nom, COUNT(Follows.id_suivi) AS followers
FROM Utilisateurs
INNER JOIN Follows ON Utilisateurs.id = Follows.id_suivi
GROUP BY Utilisateurs.nom
ORDER BY followers DESC
LIMIT 1;

-- le plus grand lieu 
PREPARE le_plus_grand_lieu AS 
SELECT adresse,nombres_places_total FROM Lieu WHERE nombres_places_total = (SELECT MAX(nombres_places_total) FROM Lieu);

-- Le concert qui a rapporté le plus 
PREPARE concert_benef AS 
SELECT Concerts.nom,  (COUNT(Participants.id_personne) * Concerts.prix) AS total_benef
FROM Concerts
JOIN Participants ON Concerts.id_concert = Participants.id_concert
GROUP BY Concerts.id_concert, Concerts.nom, Concerts.prix
ORDER BY total_benef DESC
LIMIT 1;

-- Recommandation musique en fonction du genre le plus écouté 
PREPARE recommandation_musique(INTEGER) AS
SELECT Style_musique.genre_musique, Musique.titre
FROM Musique
JOIN Style_musique ON Musique.id_musique = Style_musique.id_musique
JOIN Playlist_composition ON Musique.id_musique = Playlist_composition.id_musique
JOIN Playlist ON Playlist_composition.id_playlist = Playlist.id_playlist
WHERE Playlist.id_utilisateur = $1
AND Style_musique.genre_musique = (
  SELECT Style_musique.genre_musique
  FROM Style_musique
  JOIN Playlist_composition ON Style_musique.id_musique = Playlist_composition.id_musique
  JOIN Playlist ON Playlist_composition.id_playlist = Playlist.id_playlist
  WHERE Playlist.id_utilisateur = $1
  GROUP BY Style_musique.genre_musique
  ORDER BY COUNT(*) DESC
  LIMIT 1
);


/* nombre de personnes qui sont à deux amis de l'utilisateur
WITH RECURSIVE friends AS (
  SELECT id_suivi
  FROM Follows
  WHERE id_suiveur = 221 -- Remplacer par l'ID de l'utilisateur
  UNION
  SELECT f.id_suivi
  FROM Follows f
  JOIN friends ON f.id_suiveur = friends.id_suivi
)
SELECT COUNT(*) FROM (
  SELECT id_suivi
  FROM Follows
  WHERE id_suiveur IN (SELECT id_suivi FROM friends)
  AND id_suivi NOT IN (SELECT id_suivi FROM friends)
) AS friends_of_friends;

SELECT COUNT(pm.id_musique) AS nombre_de_musiques
FROM Playlist p
INNER JOIN Playlist_composition pm ON p.id_playlist = pm.id_playlist
GROUP BY p.nom;

SELECT (
    SELECT COUNT(*)
    FROM Playlist_composition pm
    WHERE pm.id_playlist = p.id_playlist
) AS nombre_de_musiques
FROM Playlist p;
*/