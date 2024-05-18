\! echo concert le plus cher
SELECT nom, prix
FROM Concerts
ORDER BY prix DESC
LIMIT 1;

\! echo participants qui depensent le plus
SELECT P.id_personne, T.nom, SUM(C.prix) AS total_depenses
FROM Participants P
INNER JOIN Concerts C ON P.id_concert = C.id_concert
INNER JOIN Personnes U ON U.id_personne = P.id_personne
INNER JOIN Utilisateurs T ON T.id = U.id_personne
GROUP BY P.id_personne, T.nom
ORDER BY total_depenses DESC
LIMIT 1;

DEALLOCATE recherche_note_moyenne;

/* recherche musiques d'un genre */
DEALLOCATE recherche_musiques_genre;
PREPARE recherche_musiques_genre(VARCHAR(100)) AS
SELECT M.id_musique, M.titre, A.nom
FROM Musique M
INNER JOIN Album A ON M.id_album = A.id_album
INNER JOIN Style_musique S ON M.id_musique = S.id_musique
WHERE S.genre_musique = $1;

\! echo recherches sous-genres de chaque genre */
SELECT g.*, sg.nom_sous_genre 
FROM Genre g
LEFT JOIN Sous_genre sg ON g.nom_genre = sg.genre_parent
ORDER BY g.nom_genre;

\! echo prochain concert */
SELECT id_concert, nom, heuredate 
FROM Concerts
WHERE heuredate > NOW()
ORDER BY heuredate
LIMIT 1;

\! echo le nombre de mineurs en âge parmi utilisateurs */
SELECT COUNT(*) AS nb_utilisateurs_mineurs
FROM Utilisateurs
WHERE age < 18;

DEALLOCATE recherche_note_moyenne;
PREPARE recherche_note_moyenne (VARCHAR) AS
SELECT ROUND(AVG(note), 2) as moyenne
FROM Avis
JOIN Avis_musiques ON Avis.id_avis = Avis_musiques.id_avis
JOIN Musique ON Avis_musiques.id_musique = Musique.id_musique
WHERE Musique.titre = $1;

-- Groupe le plus populaire ( le plus de concert)
SELECT Utilisateurs.nom, COUNT(Organise.id_groupe) AS nombre_concerts
FROM Utilisateurs
INNER JOIN Groupes ON Utilisateurs.id = Groupes.id_groupe
INNER JOIN Organise ON Groupes.id_groupe = Organise.id_groupe
GROUP BY Utilisateurs.nom
ORDER BY nombre_concerts DESC
LIMIT 1;

-- Age moyen des utilisateurs 
SELECT AVG(age) AS age_moyen FROM Utilisateurs;

-- Concert le mieux noté 
SELECT Concerts.nom, AVG(Avis.note) AS moyenne_notes
From Concerts
INNER JOIN Avis_concerts ON Concerts.id_concert = Avis_concerts.id_concert
INNER JOIN Avis ON Avis_concerts.id_avis = Avis.id_avis
GROUP BY Concerts.nom
ORDER BY moyenne_notes DESC
LIMIT 1;

-- Concert le plus célèbre ( le plus de participants ) 
SELECT Concerts.nom, COUNT(Participants.id_personne) AS participants
FROM Concerts
INNER JOIN Participants ON Participants.id_concert = Concerts.id_concert
GROUP BY Concerts.nom
ORDER BY participants DESC
LIMIT 1;

-- Utilisateur le plus suivi 
SELECT Utilisateurs.nom, COUNT(Follows.id_suivi) AS followers
FROM Utilisateurs
INNER JOIN Follows ON Utilisateurs.id = Follows.id_suivi
GROUP BY Utilisateurs.nom
ORDER BY followers DESC
LIMIT 1;

-- Le plus grand lieu 
SELECT adresse,nombres_places_total FROM Lieu WHERE nombres_places_total = (SELECT MAX(nombres_places_total) FROM Lieu);

-- Le concert qui a rapporté le plus 
SELECT Concerts.nom,  (COUNT(Participants.id_personne) * Concerts.prix) AS total_benef
FROM Concerts
JOIN Participants ON Concerts.id_concert = Participants.id_concert
GROUP BY Concerts.id_concert, Concerts.nom, Concerts.prix
ORDER BY total_benef DESC
LIMIT 1;


DROP VIEW IF EXISTS vue_recommandation_concerts cascade;
CREATE OR REPLACE VIEW vue_recommandation_concerts AS
SELECT c.id_concert,
    c.nom,
    l.ville,
    l.etat,
    TO_CHAR(DATE_TRUNC('day', c.heuredate), 'DD/MM/YYYY') AS dateconcert,
    COALESCE(ROUND((AVG(a.note) * 0.5 + 
    COUNT(p.id_personne) * 0.3 + 
    COUNT(i.id_personne) * 0.2)::numeric, 2),0) AS recommandation
FROM Concerts c
JOIN Organise o ON o.id_concert = c.id_concert
JOIN Lieu l ON l.adresse = c.adresse
JOIN Groupes g ON g.id_groupe = o.id_groupe
LEFT JOIN Participants p ON p.id_concert = c.id_concert
LEFT JOIN Interesses i ON i.id_concert = c.id_concert
LEFT JOIN Avis_concerts ac ON ac.id_concert = c.id_concert
LEFT JOIN Avis a ON a.id_avis = ac.id_avis
WHERE c.heuredate > CURRENT_DATE
  AND c.heuredate < CURRENT_DATE + INTERVAL '6 months'
GROUP BY c.id_concert, c.nom, l.ville, l.etat, c.heuredate
;

DEALLOCATE recommandation_concerts_utilisateur;
PREPARE recommandation_concerts_utilisateur(text, text, integer) AS
SELECT *
FROM vue_recommandation_concerts
WHERE (ville = (SELECT ville FROM Utilisateurs WHERE nom = $1 AND email = $2) 
  OR etat = (SELECT etat FROM Utilisateurs WHERE nom = $1 AND email = $2))
ORDER BY recommandation DESC
LIMIT $3;

-- Prochain groupe a jouer organisant un concert 
SELECT Utilisateurs.nom, Concerts.nom, Concerts.heuredate
FROM Utilisateurs
INNER JOIN Groupes ON Groupes.id_groupe = Utilisateurs.id
INNER JOIN Organise ON Groupes.id_groupe = Organise.id_groupe
INNER JOIN Concerts ON Organise.id_concert = Concerts.id_concert
WHERE Concerts.heuredate >= CURRENT_DATE
ORDER BY Concerts.heuredate ASC
LIMIT 1;

-- Recommandation musique en fonction du genre le plus écouté 
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

