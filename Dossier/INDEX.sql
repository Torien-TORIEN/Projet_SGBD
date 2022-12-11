-------------------------------------------- TABLE CLIENT -------------------------------------------------
CREATE INDEX Idx_Clt_NomPrenom ON Client(nomClt,prenomClt);
-------------------------------------------- TABLE ARTISTE ------------------------------------------------
CREATE INDEX Idx_Art_NomArt ON Artiste(nomArt);
CREATE INDEX Idx_Art_Spclt ON Artiste(specialite);
-------------------------------------------- TABLE LIEU   -------------------------------------------------
CREATE INDEX Idx_Lieu_NomL ON Lieu(nomLieu);
CREATE INDEX Idx_Lieu_Capacite ON Lieu(capacite);
-------------------------------------------- TABLE SPECTACLE------------------------------------------------
CREATE INDEX Idx_Spec_Titre ON Spectacle(titre);
CREATE INDEX Idx_Spec_dateHeure ON Spectacle(dateS,H_debut);
CREATE INDEX Idx_Spec_Lieu ON Spectacle(idLieu);

-------------------------------------------- TABLE RUBRIQUE ------------------------------------------------
CREATE INDEX Idx_Rub_IdSpec ON Rubrique(idSpec);
CREATE INDEX Idx_Rub_IdAt ON Rubrique(idArt);
CREATE INDEX Idx_Rub_Type ON Rubrique(Type);
----------------------------------------- TABLE BILLET -----------------------------------------------------
CREATE INDEX Idx_Bill_Cat ON Billet(categorie);
CREATE INDEX Idx_Bill_Vendu ON Billet(Vendu);

COMMIT;