DROP TABLE IF EXISTS Avis_concerts cascade;
DROP TABLE IF EXISTS Avis_groupes cascade;
DROP TABLE IF EXISTS Avis_musiques cascade;
DROP TABLE IF EXISTS Avis cascade;
DROP TABLE IF EXISTS Follows cascade;
DROP TABLE IF EXISTS Interesses cascade;
DROP TABLE IF EXISTS Participants cascade;
DROP TABLE IF EXISTS Organise cascade;
DROP TABLE IF EXISTS Annonces cascade;
DROP TABLE IF EXISTS Concerts_Futurs cascade;
DROP TABLE IF EXISTS Concerts_passes cascade;
DROP TABLE IF EXISTS Concerts cascade;
DROP TABLE IF EXISTS Lieu cascade;
DROP TABLE IF EXISTS Playlist_composition cascade;
DROP TABLE IF EXISTS Sous_genre cascade;
DROP TABLE IF EXISTS Style_musique cascade;
DROP TABLE IF EXISTS Musique cascade;
DROP TABLE IF EXISTS Album cascade;
DROP TABLE IF EXISTS Playlist cascade;
DROP TABLE IF EXISTS Genre cascade;
DROP TABLE IF EXISTS Groupes cascade;
DROP TABLE IF EXISTS Associations cascade;
DROP TABLE IF EXISTS Personnes cascade;
DROP TABLE IF EXISTS Utilisateurs cascade;

CREATE TABLE Utilisateurs (
    id INTEGER PRIMARY KEY NOT NULL,
    nom VARCHAR(100) NOT NULL,
    age INTEGER,
    email VARCHAR(255) NOT NULL,
    ville VARCHAR(255) NOT NULL,
    etat VARCHAR(255) NOT NULL,
    UNIQUE (email)
);

CREATE TABLE Follows (
    id_suiveur INTEGER NOT NULL,
    id_suivi INTEGER NOT NULL CONSTRAINT different_follow CHECK (id_suivi <> id_suiveur),
    FOREIGN KEY (id_suiveur) REFERENCES Utilisateurs(id) ON DELETE CASCADE,
    FOREIGN KEY (id_suivi) REFERENCES Utilisateurs(id) ON DELETE CASCADE--,
    -- CONSTRAINT unique_follow UNIQUE (id_suivi, id_suiveur),
    -- CONSTRAINT different_follow CHECK (id_suivi <> id_suiveur)
);

CREATE TABLE Lieu (
    id_lieu INTEGER PRIMARY KEY NOT NULL,
    nombres_places_total INTEGER NOT NULL,
    adresse VARCHAR(255) NOT NULL,
    ville VARCHAR(255) NOT NULL,
    etat VARCHAR(255) NOT NULL,
    UNIQUE (adresse)
);

CREATE TABLE Concerts (
    id_concert INTEGER PRIMARY KEY NOT NULL,
    adresse VARCHAR(255) NOT NULL,
    nom VARCHAR(255) NOT NULL,
    prix INTEGER NOT NULL,
    heuredate TIMESTAMP NOT NULL,
    UNIQUE (id_concert),
    FOREIGN KEY (adresse) REFERENCES Lieu(adresse) ON DELETE CASCADE
);

CREATE TABLE Concerts_passes(
    id_concert INTEGER NOT NULL,
    places_vendues INTEGER NOT NULL,
    FOREIGN KEY (id_concert) REFERENCES Concerts(id_concert) ON DELETE CASCADE
);

CREATE TABLE Concerts_Futurs(
    id_concert INTEGER NOT NULL,
    places_restantes INTEGER NOT NULL,
    FOREIGN KEY (id_concert) REFERENCES Concerts(id_concert) ON DELETE CASCADE
);

CREATE TABLE Groupes(
    id_groupe INTEGER NOT NULL,
    UNIQUE (id_groupe),
    FOREIGN KEY (id_groupe) REFERENCES Utilisateurs(id) ON DELETE CASCADE
);

CREATE TABLE Associations(
    id_association INTEGER NOT NULL,
    UNIQUE (id_association),
    FOREIGN KEY (id_association) REFERENCES Utilisateurs(id) ON DELETE CASCADE
);

CREATE TABLE Personnes(
    id_personne INTEGER NOT NULL,
    UNIQUE (id_personne),
    FOREIGN KEY (id_personne) REFERENCES Utilisateurs(id) ON DELETE CASCADE
);

CREATE TABLE Annonces(
    id_association INTEGER NOT NULL,
    id_concert INTEGER NOT NULL,
    FOREIGN KEY (id_association) REFERENCES Associations(id_association) ON DELETE CASCADE,
    FOREIGN KEY (id_concert) REFERENCES Concerts(id_concert) ON DELETE CASCADE
);

CREATE TABLE Organise(
    id_groupe INTEGER NOT NULL,
    id_concert INTEGER NOT NULL,
    FOREIGN KEY (id_groupe) REFERENCES Groupes(id_groupe) ON DELETE CASCADE,
    FOREIGN KEY (id_concert) REFERENCES Concerts(id_concert) ON DELETE CASCADE
);

CREATE TABLE Participants(
    id_personne INTEGER NOT NULL,
    id_concert INTEGER NOT NULL,
    FOREIGN KEY (id_personne) REFERENCES Personnes(id_personne) ON DELETE CASCADE,
    FOREIGN KEY (id_concert) REFERENCES Concerts(id_concert) ON DELETE CASCADE
);

CREATE TABLE Interesses(
    id_personne INTEGER NOT NULL,
    id_concert INTEGER NOT NULL,
    FOREIGN KEY (id_personne) REFERENCES Personnes(id_personne) ON DELETE CASCADE,
    FOREIGN KEY (id_concert) REFERENCES Concerts(id_concert) ON DELETE CASCADE
);

CREATE TABLE Playlist(
    id_playlist INTEGER PRIMARY KEY NOT NULL,
    id_utilisateur INTEGER NOT NULL,
    nom VARCHAR(100) NOT NULL,
    UNIQUE (id_playlist),
    FOREIGN KEY (id_utilisateur) REFERENCES Personnes(id_personne) ON DELETE CASCADE
);

CREATE TABLE Album(
    id_album INTEGER PRIMARY KEY NOT NULL,
    nom VARCHAR(100) NOT NULL,
    UNIQUE (id_album, nom)
);

CREATE TABLE Musique(
    id_musique INTEGER PRIMARY KEY NOT NULL,
    titre VARCHAR(100) NOT NULL,
    id_album INTEGER NOT NULL,
    id_groupe INTEGER,
    FOREIGN KEY (id_album) REFERENCES Album(id_album) ON DELETE CASCADE,
    FOREIGN KEY (id_groupe) REFERENCES Groupes(id_groupe) ON DELETE CASCADE,
    UNIQUE (id_musique, titre)
);

CREATE TABLE Playlist_composition(
    id_playlist INTEGER NOT NULL,
    id_musique INTEGER NOT NULL,
    FOREIGN KEY (id_playlist) REFERENCES Playlist(id_playlist) ON DELETE CASCADE,
    FOREIGN KEY (id_musique) REFERENCES Musique(id_musique) ON DELETE CASCADE
);

CREATE TABLE Genre(
    nom_genre VARCHAR(100) NOT NULL,
    PRIMARY KEY (nom_genre),
    UNIQUE (nom_genre)
);

CREATE TABLE Sous_genre(
    genre_parent VARCHAR(100) NOT NULL,
    nom_sous_genre VARCHAR(100) NOT NULL,
    FOREIGN KEY (nom_sous_genre) REFERENCES GENRE(nom_genre) ON DELETE CASCADE,
    FOREIGN KEY (genre_parent) REFERENCES GENRE(nom_genre) ON DELETE CASCADE
);

CREATE TABLE Style_musique(
    id_musique INTEGER NOT NULL,
    genre_musique VARCHAR(100) NOT NULL,
    FOREIGN KEY (id_musique) REFERENCES Musique(id_musique) ON DELETE CASCADE,
    FOREIGN KEY (genre_musique) REFERENCES GENRE(nom_genre) ON DELETE CASCADE
);

CREATE TABLE Avis(
    id_avis SERIAL PRIMARY KEY NOT NULL,
    id_utilisateur INTEGER NOT NULL,
    commentaire TEXT NOT NULL,
    note INTEGER NOT NULL,
    UNIQUE (id_avis),
    FOREIGN KEY (id_utilisateur) REFERENCES Utilisateurs(id) ON DELETE CASCADE
);

CREATE TABLE Avis_concerts(
    id_avis INTEGER NOT NULL,
    id_concert INTEGER NOT NULL,
    FOREIGN KEY (id_avis) REFERENCES Avis(id_avis) ON DELETE CASCADE,
    FOREIGN KEY (id_concert) REFERENCES Concerts(id_concert) ON DELETE CASCADE
);

CREATE TABLE Avis_groupes(
    id_avis INTEGER NOT NULL,
    id_groupe INTEGER NOT NULL,
    FOREIGN KEY (id_avis) REFERENCES Avis(id_avis) ON DELETE CASCADE,
    FOREIGN KEY (id_groupe) REFERENCES Groupes(id_groupe) ON DELETE CASCADE
);

CREATE TABLE Avis_musiques(
    id_avis INTEGER NOT NULL,
    id_musique INTEGER NOT NULL,
    FOREIGN KEY (id_avis) REFERENCES Avis(id_avis) ON DELETE CASCADE,
    FOREIGN KEY (id_musique) REFERENCES Musique(id_musique) ON DELETE CASCADE
);

ALTER TABLE Concerts ADD CONSTRAINT prix CHECK (prix >= 0);
ALTER TABLE Lieu ADD CONSTRAINT nombres_places_total CHECK (nombres_places_total >= 0);
ALTER TABLE Concerts_Passes ADD CONSTRAINT places_vendues CHECK (places_vendues >= 0);
ALTER TABLE Concerts_Futurs ADD CONSTRAINT places_restantes CHECK (places_restantes >= 0);
ALTER TABLE Utilisateurs ADD CONSTRAINT age CHECK (age >= 10);

\copy Utilisateurs(id,nom, age, email,ville,etat) FROM 'CSV/Utilisateurs.csv' DELIMITER ',' CSV HEADER;
\copy Personnes(id_personne) FROM 'CSV/Personnes.csv' DELIMITER ',' CSV HEADER;
\copy Associations(id_association) FROM 'CSV/Associations.csv' DELIMITER ',' CSV HEADER;
\copy Groupes(id_groupe) FROM 'CSV/Groupes.csv' DELIMITER ',' CSV HEADER;
\copy Genre(nom_genre) FROM 'CSV/Genre.csv' DELIMITER ',' CSV HEADER;
\copy Playlist(id_playlist,id_utilisateur, nom) FROM 'CSV/Playlist.csv' DELIMITER ',' CSV HEADER;
\copy Album(id_album,nom) FROM 'CSV/Album.csv' DELIMITER ',' CSV HEADER;
\copy Musique(id_musique,titre, id_album, id_groupe) FROM 'CSV/Musique.csv' DELIMITER ',' CSV HEADER;
\copy Style_musique(id_musique, genre_musique) FROM 'CSV/Style_musique.csv' DELIMITER ',' CSV HEADER;
\copy Sous_genre(genre_parent, nom_sous_genre) FROM 'CSV/Sous_genre.csv' DELIMITER ',' CSV HEADER;
\copy Playlist_composition(id_playlist, id_musique) FROM 'CSV/Playlist_composition.csv' DELIMITER ',' CSV HEADER;
\copy Lieu(id_lieu,nombres_places_total,adresse,ville,etat) FROM 'CSV/Lieu.csv' DELIMITER ',' CSV HEADER;
\copy Concerts(id_concert, adresse,nom,prix,heuredate) FROM 'CSV/Concerts.csv' DELIMITER ',' CSV HEADER;
\copy Annonces(id_association, id_concert) FROM 'CSV/Annonces.csv' DELIMITER ',' CSV HEADER;
\copy Organise(id_groupe, id_concert) FROM 'CSV/Organise.csv' DELIMITER ',' CSV HEADER;
\copy Participants(id_personne, id_concert) FROM 'CSV/Participants.csv' DELIMITER ',' CSV HEADER;
\copy Interesses(id_personne, id_concert) FROM 'CSV/Interesses.csv' DELIMITER ',' CSV HEADER;
\copy Follows(id_suiveur,id_suivi) FROM 'CSV/Follows.csv' DELIMITER ',' CSV HEADER;
\copy Avis(id_avis,id_utilisateur, commentaire, note) FROM 'CSV/Avis.csv' DELIMITER ',' CSV HEADER;
\copy Avis_musiques(id_avis, id_musique) FROM 'CSV/Avis_musiques.csv' DELIMITER ',' CSV HEADER;
\copy Avis_groupes(id_avis, id_groupe) FROM 'CSV/Avis_groupes.csv' DELIMITER ',' CSV HEADER;
\copy Avis_concerts(id_avis, id_concert) FROM 'CSV/Avis_concerts.csv' DELIMITER ',' CSV HEADER;

INSERT INTO Concerts_passes (id_concert, places_vendues)
SELECT id_concert, COUNT(*) AS places_vendues
FROM Participants
WHERE id_concert IN (SELECT id_concert FROM Concerts WHERE heuredate < NOW())
GROUP BY id_concert;

INSERT INTO Concerts_futurs (id_concert, places_restantes)
SELECT c.id_concert, l.nombres_places_total - COUNT(p.id_personne)
FROM Concerts c
INNER JOIN Lieu l ON c.adresse = l.adresse
LEFT JOIN Participants p ON p.id_concert = c.id_concert
WHERE c.heuredate > now() AND c.id_concert NOT IN (SELECT id_concert FROM Concerts_passes)
GROUP BY c.id_concert, l.nombres_places_total;

INSERT INTO Musique (id_musique,titre, id_album, id_groupe)
VALUES
  (999,'Eleanor Rigby', 1, NULL),
  (1024,'Hey Jude',1, NULL),
  (729,'Here Comes the Sun', 1, NULL);

DELETE FROM Playlist
WHERE id_playlist NOT IN (
    SELECT t.id_playlist
    FROM (
        SELECT id_playlist, ROW_NUMBER() OVER (
            PARTITION BY id_utilisateur
            ORDER BY id_playlist
        ) AS row_num
        FROM Playlist
    ) t
    WHERE row_num <= 10
);

DELETE FROM Playlist_composition
WHERE id_playlist IN (
    SELECT id_playlist
    FROM (
        SELECT id_playlist, ROW_NUMBER() OVER (
            PARTITION BY id_playlist
            ORDER BY id_playlist
        ) AS row_num
        FROM Playlist_composition
    ) t
    WHERE row_num > 20
);

DELETE FROM Interesses I
WHERE id_personne IN (
    SELECT DISTINCT id_personne
    FROM Participants
    WHERE id_concert = I.id_concert
);

DELETE FROM Playlist
WHERE id_playlist IN (
    SELECT p.id_playlist
    FROM Playlist p
    JOIN Playlist_composition pc ON p.id_playlist = pc.id_playlist
    JOIN Musique m ON pc.id_musique = m.id_musique
    JOIN Groupes g ON p.id_utilisateur = g.id_groupe
    WHERE g.id_groupe <> m.id_groupe
);