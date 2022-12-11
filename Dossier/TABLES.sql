************** TABLE LIEU ******************

CREATE TABLE Lieu
	(idLieu INTEGER PRIMARY KEY,
	NomLieu VARCHAR2 (30) NOT NULL,
	Adresse VARCHAR2 (100) NOT NULL,
      capacite NUMBER NOT NULL,
	CONSTRAINT chk_Lieu_capacite CHECK (capacite BETWEEN 100 AND 2000)
	);

************** TABLE ARTISTE ******************


CREATE TABLE Artiste
	(idArt INTEGER PRIMARY KEY,
	NomArt VARCHAR2 (30) NOT NULL,
	PrenomArt VARCHAR2 (30) NOT NULL,
        specialite VARCHAR2 (10) NOT NULL,
	CONSTRAINT chk_artiste_specialite CHECK(specialite IN ('danseur', 'acteur','musicien', 'magicien', 'imitateur', 'humoriste', 'chanteur'))
	);

************** TABLE SPECTACLE******************

CREATE TABLE SPECTACLE(
	idSpec INTEGER PRIMARY KEY,
	Titre VARCHAR2 (40) NOT NULL,
             dateS DATE,-- peut  être NULL pour un spectacle annulé
              h_debut NUMBER(4,2) NOT NULL,
	dureeS NUMBER(4,2) NOT NULL,
             nbrSpectateur INTEGER NOT NULL,
	idLieu INTEGER,
	CONSTRAINT chk_spect_durees CHECK (dureeS BETWEEN 1 AND 4),
            CONSTRAINT FK_spect_Lieux FOREIGN KEY(idLieu) REFERENCES Lieu (idLieu)
);
************** TABLE RUBRIQUE******************

CREATE TABLE Rubrique
	(idRub INTEGER PRIMARY KEY, 
	 idSpec INTEGER NOT NULL, 
	 idArt INTEGER NOT NULL, 
	 H_debutR NUMBER(4,2) NOT NULL, 
       dureeRub NUMBER(4,2) NOT NULL, 
      type VARCHAR2(10), 
      CONSTRAINT fk_rub_spect FOREIGN KEY(idSpec) REFERENCES SPECTACLE(idSpec) ON DELETE CASCADE,
	CONSTRAINT fk_rub_art FOREIGN KEY(idArt)  REFERENCES Artiste(idArt) ON DELETE CASCADE,
	CONSTRAINT chk_Rubrique_type CHECK(type IN ('comedie', 'théatre', 'dance', 'imitation', 'magie','musique', 'chant'))
 	);

************** TABLE BILLETS******************
CREATE TABLE BILLET(
	idBillet INTEGER PRIMARY KEY,
	categorie VARCHAR2(10),
	prix NUMBER(5,2) NOT NULL,
	idspec INTEGER NOT NULL ,
	Vendu VARCHAR(3) NOT NULL, 
             CONSTRAINT chk_billet_PRIX CHECK(prix BETWEEN 10 AND 300),
             CONSTRAINT fk_billet_spec FOREIGN KEY (idspec) REFERENCES spectacle(idSpec),
             CONSTRAINT chk_billet_vendu CHECK(vendu IN ('Oui','Non')),
             CONSTRAINT chk_billet_categorie CHECK(categorie IN ('Gold','silver', 'normale'))
);


ALTER TABLE Lieu ADD (Est_supprime VARCHAR(3) DEFAULT 'Non' NOT NULL,
CONSTRAINT ck_lieu_supprime CHECK (Est_supprime IN ('Oui','Non') ));
COMMIT;
--ROLLBACK;
     