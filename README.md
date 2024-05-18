
# Project Title

Bases de données: NoiseBook

## Usage/Examples

```sql
1.installer psql
2.décompresser le dépôt
3.lancer psql sur le répertoire contenant les fichiers
4. \i test.sql
5. \i requetes.sql
```

## Tables

Album(id_album,nom)
Annonces(id_association,id_concert)
Associations(id_association)
Avis_concerts(id_avis,id_concert)
Avis_groupes(id_avis,id_groupe)
Avis_musique(id_avis,id_musique)
Avis(id_avis,id_utilisateur,commentaire,note)
Follows(id_suiveur,id_suivi)
Genre(nom_genre)
Groupes(id_groupe)
Interesses(id_personne,id_concert)
Lieu(id_lieu,nombres_places_total,adresse,ville,etat)
Musique(id_musique,titre,id_album,id_groupe)
Organise(id_groupe,id_concert)
Personnes(id_personne)
Playlist_composition(id_playlist,id_musique)
Participants(id_personne,id_concert)
Concerts(id_concert,id_lieu,nom,prix,heuredate)
Playlist(id_playlist,id_utilisateur,nom)
Sous_genre(genre_parent,nom_sous_genre)
Style_musique(id_musique,genre_musique)
Utilisateurs(id,nom,age,email,ville,etat)

## Liste des commandes à lancer avec EXECUTE

- Nom et lieu du groupe organisateur pour chaque concert:
```
EXECUTE recherche_concerts;
```
- Rechercher les amis d'un utilisateur:
```
EXECUTE recherche_amis(NAME,MAIL);
```
- Concerts qui ont plus de n participants:
```
EXECUTE recherche_concerts_participants(INTEGER);
```
- Le Nombre de concerts auxquels chaque utilisateur a participé:
```
EXECUTE recherche_nb_concerts;
```
- Nom des utilisateurs qui suivent au moins deux autres utilisateurs:
```
EXECUTE recherche_suiveurs;
```
- Afficher les sous-genres de chaque genre:
```
EXECUTE recherche_sous_genres;
```
- Les utilisateurs ayant participé à au moins 5 concerts dont le prix moyen est supérieur à 20:
```
EXECUTE recherche_utilisateurs;
```
- Les listes de groupes ayant une moyenne de notes des avis supérieure à 3.5:
```
EXECUTE recherche_groupes;
```
- La moyenne des notes maximales données par les utilisateurs:
```
EXECUTE recherche_moyenne_max_notes;
```
- Les dix groupes les plus populaires pour chaque mois de 2022 selon les personnes interessés:
```
EXECUTE recherche_concerts_populaires;
```
- Les n recommandations de concerts à venir que l'on peut suggérer d'un utilisateur en fonction de sa localisation géographique:
```
EXECUTE recommandation_concerts_utilisateur(NAME,MAIL,INTEGER);
```
- Groupe le plus populaire ( le plus de concert)
```
EXECUTE groupe_populaire;
```
- Age moyen des utilisateurs 
```
EXECUTE age_moyen;
```
- Concert le mieux noté 
```
EXECUTE conert_le_mieux_note;
```
- Concert le plus célèbre ( le plus de participants ) 
```
EXECUTE concert_le_plus_célèbre;
```
- Utilisateur le plus suivi 
```
EXECUTE utilisateur_le_plus_suivi;
```
- le plus grand lieu 
```
EXECUTE le_plus_grand_lieu;
```
- Le concert qui a rapporté le plus 
```
EXECUTE concert_benef;
```
- recommande les musique en fonction du genre le plus écouté de l'utilisateur
```
EXECUTE recommandation_musique(ID_USER);
```