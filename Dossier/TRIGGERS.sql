-------------------------------------------- TABLE CLIENT -------------------------------------------------
CREATE OR REPLACE TRIGGER Trig_Client_email_tel
BEFORE INSERT OR UPDATE OF tel,email
ON Client
FOR EACH ROW
BEGIN
	------------------- Téléphone --------------------
	IF(NOT REGEXP_LIKE (:NEW.tel , '(2|4|5|9)\d\d\d\d\d\d\d$') ) THEN
		RAISE_APPLICATION_ERROR(-20100,'Tel : '|| :NEW.tel ||' est invalide !!');
	END IF;
	--------------------- Email ----------------------
	IF(NOT REGEXP_LIKE (:NEW.email , '[A-Z0-9._%-]+@[A-Z0-9._%-]+\.[A-Z]{2,4}')) THEN
		RAISE_APPLICATION_ERROR(-20100,'Email :'||:NEW.email||' est invalide !!');
	END IF;
END;
/
------------------------------ Tel invalide ----------------------------------
INSERT INTO Client VALUES (1,'Torien','Torien',5177331,'torien1227@gmail.com','123');
------------------------------ Email invalide ----------------------------------
INSERT INTO Client VALUES (1,'Torien','Torien',51773315,'torien1227gmail.com','123');

/

-------------------------------------------- TABLE ARTISTE ------------------------------------------------

-------------------------------------------- TABLE LIEU   -------------------------------------------------
/
CREATE OR REPLACE TRIGGER Trig_Lieu_Supprime
BEFORE DELETE
ON Lieu
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
	VnbrS NUMERIC;
BEGIN
     SELECT COUNT(idSpec)INTO VnbrS FROM Spectacle WHERE idLieu=:OLD.idLieu;
     IF(VnbrS>0) THEN
         UPDATE Lieu SET Est_supprime='Oui' WHERE idLieu=:OLD.idLieu;
         COMMIT;
	    RAISE_APPLICATION_ERROR(-20101,'Suppression physique Impossible mais Suppression logique a eu lieu  !!');
     END IF;
END;

/

INSERT INTO SPECTACLE VALUES(Seq_idSpec.NEXTVAL,'Festival ENICAR','15-12-2022',20,4,100,1);
COMMIT;
INSERT INTO SPECTACLE VALUES(2,'Festival ENICAR','15-12-2022',20,4,100,1);

SELECT * FROM Lieu WHERE idLieu=1;

DELETE Lieu WHERE idLieu=1;

/
-------------------------------------------- TABLE SPECTACLE------------------------------------------------
/
CREATE OR REPLACE TRIGGER Trig_Spect_capacite
BEFORE INSERT OR UPDATE OF nbrSpectateur
ON Spectacle
FOR EACH ROW
DECLARE
	Vnbr NUMERIC;
	Vcap Lieu.capacite%TYPE ;
BEGIN
     SELECT COUNT(idLieu)INTO Vnbr FROM Lieu WHERE idLieu=:NEW.idLieu;
     IF(Vnbr>0) THEN
         SELECT capacite INTO Vcap FROM Lieu WHERE idLieu=:NEW.idLieu;
         IF (Vcap < :NEW.nbrSpectateur) THEN
	         RAISE_APPLICATION_ERROR(-20102,'Le nombre de spectateurs depasse la capacité du lieu :'|| Vcap||' !!');
	    END IF;
     END IF;
END;
/
------- Capacite de Lieu N° 2---
SELECT Capacite FROM Lieu WHERE idLieu=2;

----- Inserer un spectacle avec le nombre de spectateur > sa capacité----
INSERT INTO SPECTACLE VALUES(2,'Grand Spectacle ','19-12-2022',16.3,3,700,2);
/
CREATE OR REPLACE TRIGGER Trig_Spec_date
BEFORE INSERT OR UPDATE OF dateS
ON Spectacle
FOR EACH ROW
BEGIN
     IF(:NEW.DateS < SYSDATE) THEN 
                          RAISE_APPLICATION_ERROR(-20103,'La date de spectacle doit etre supériere à '|| SYSDATE);
     END IF ;
END;
/
------------------- Inserer spectacle avec une date déjà passé ------------
INSERT INTO SPECTACLE VALUES(2,'Grand Spectacle ','19-12-2006',16.3,3,100,2);


/
CREATE OR REPLACE TRIGGER Trig_Spec_DispoLieu
BEFORE INSERT OR UPDATE OF idLieu
ON SPECTACLE  
FOR EACH ROW
DECLARE
     HeureD Spectacle.durees%TYPE;
     HeureF Spectacle.durees%TYPE;
     Vnbr NUMERIC;
BEGIN
    HeureD:= :NEW.H_Debut;
    HeureF:= :NEW.H_Debut+ :NEW.DureeS;

    SELECT COUNT(idSpec) INTO Vnbr FROM Spectacle WHERE idLieu = :NEW.idLieu AND dates = :NEW.dateS 
    AND(  (H_DEBUT<=HeureD AND HeureD < H_DEBUT+DureeS ) OR (HeureD < H_Debut AND H_Debut < HeureF)  );
    
    IF (Vnbr>0)THEN
        RAISE_APPLICATION_ERROR(-20104,'CE LIEU EST DEJA OCCUPE POUR LE MOMENT CHOISI !!!');
    END IF;
END;
/
------------- Voir ce qu'il y'a dans la table spectacle ----------------
SELECT * FROM SPECTACLE ;

------------- Ajouter un spectacle sur le meme lieu et avec date incompatible ----------------
INSERT INTO SPECTACLE VALUES(2,'Grand Spectacle ','15-12-2022',21,3,100,1);

/
CREATE OR REPLACE TRIGGER Trig_Spec_SupLieu
BEFORE INSERT OR UPDATE OF idLieu
ON Spectacle
FOR EACH ROW
DECLARE
     Vetat Lieu.Est_supprime%TYPE ;
BEGIN
     SELECT Est_supprime INTO Vetat FROM Lieu WHERE idLieu= :NEW.idLieu ;

     IF(Vetat ='Oui' ) THEN 
                      RAISE_APPLICATION_ERROR(-20105,'Ce lieu est déjà supprimé logiquement !! ');
     END IF ;

     EXCEPTION
     WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20105,'Aucun lieu trouvé avec id=' || :NEW.idLieu);
END;
/

----------- Ajouter un spectacle sur le meme lieu déjà supprimé logiquement ---------
INSERT INTO SPECTACLE VALUES(2,'Grand Spectacle ','16-12-2022',21,3,100,1);

/
CREATE OR REPLACE TRIGGER Tri_Spec_MAJ_Hdebut
AFTER UPDATE OF H_Debut
ON Spectacle
FOR EACH ROW 
DECLARE
    VnRub NUMERIC;
    Vdecalage Spectacle.H_debut%TYPE:= :NEW.H_debut-:OLD.H_debut;
BEGIN
    SELECT COUNT (idRub) INTO VnRub FROM Rubrique WHERE idSpec = :NEW.idSpec;
    IF(VnRub >0) THEN
        ----------- Metre à jour H_debutR -------------
        UPDATE Rubrique SET H_debutR=H_debutR+Vdecalage WHERE idSpec = :NEW.idSpec;
    END IF;
END;
/
INSERT INTO SPECTACLE VALUES(Seq_idSpec.NEXTVAL,'Grand Theatre ','20-12-2022',10,3,500,2);--id=2
INSERT INTO ARTISTE VALUES(Seq_idArt.NEXTVAL,'Mohammed','ALI','humoriste');--id=10
INSERT INTO Rubrique VALUES (Seq_idRub.NEXTVAL,2,10,10,1.5,'théatre');
COMMIT;

--Selection de rubrique avant la mise à jour de H_debu---------------
SELECT * FROM RUBRIQUE WHERE idSpec=2;

--- Metre à jour Spectacle 2 :H_debut=H_debut+2 ----
UPDATE SPECTACLE SET H_debut=12 WHERE idSpec=2;
COMMIT;
--Selection de rubrique avant la mise à jour de H_debu---------------
SELECT * FROM RUBRIQUE WHERE idSpec=2;
/

CREATE OR REPLACE TRIGGER Trig_Spec_MAJ_DureeS
AFTER UPDATE OF DureeS
ON Spectacle
FOR EACH ROW 
DECLARE
    VnRub NUMERIC;
    Vdecalage Spectacle.DureeS%TYPE:=  :NEW.DureeS-:OLD.DureeS;
    VnFinSpec Spectacle.DureeS%TYPE:=  :NEW.H_debut+:NEW.DureeS;
BEGIN
    ----  Tester si on dimunié la durée du spectacle ----------
    IF(Vdecalage < 0) THEN

        ----  Tester s'il y des rubriques affectées cad la heure Fin de rub > heure Fin de Spect  ----------
        SELECT COUNT (idRub) INTO VnRub FROM Rubrique 
       WHERE idSpec = :NEW.idSpec AND (H_debutR + DureeRub)>(:NEW.H_debut+:NEW.dureeS);

        IF(VnRub >0) THEN
            ----------- Metre à jour DuréeRub -------------
            UPDATE Rubrique SET DureeRub=VnFinSpec - h_debutR
            WHERE idSpec = :NEW.idSpec AND (H_debutR + DureeRub)>(:NEW.H_debut+:NEW.dureeS);

            ------ Supprimer rubriques dont da durée < 0 -----
            DELETE FROM Rubrique WHERE DureeRub <0;
        END IF;
    END IF;
END;


/
------------------------- Avant la mise à jour  ----------------------------------------
SELECT h_debut,dureeS,h_debutR,dureeRub FROM Rubrique R ,Spectacle S WHERE S.idSpec=R.idSpec AND S.idSpec=2;


UPDATE Spectacle SET dureeS=1 WHERE idSpec=2;
COMMIT;
------------------------- Après la mise à jour  ----------------------------------------
SELECT h_debut,dureeS,h_debutR,dureeRub FROM Rubrique R ,Spectacle S WHERE S.idSpec=R.idSpec AND S.idSpec=2;

-------------------------------------------- TABLE RUBRIQUE ------------------------------------------------
/
CREATE OR REPLACE TRIGGER Trig_Spec_rubrique
BEFORE INSERT OR UPDATE OF H_debutR,DureeRub
ON Rubrique
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
	VnbrS NUMERIC;
	VnbrR NUMERIC;
	Vspec Spectacle%ROWTYPE;
             VH_FinS         Spectacle.h_debut%TYPE;
             VH_FinRub    Rubrique.h_debutR%TYPE :=     :NEW.H_debutR+:NEW.dureeRub;
BEGIN 
	SELECT COUNT(idSpec) INTO VnbrS FROM Spectacle WHERE idSpec=:NEW.idSpec;
	IF(VnbrS>0) THEN
		SELECT * INTO Vspec FROM Spectacle WHERE idSpec=:NEW.idSpec;
                            VH_FinS:=Vspec.H_debut+Vspec.DureeS;

		----------------------- Vérifier le nombre de rubriques (<=3)  -------------------
		SELECT COUNT(idRub) INTO VnbrR FROM Rubrique WHERE idSpec=:NEW.idSpec;
		IF (INSERTING AND VnbrR>2) THEN 
			RAISE_APPLICATION_ERROR(-20106,'Vous ne pouvez pas ajouter une autre rubrique à ce spéctale car le nombre max 3 est atteint');
		END IF;

	  ------------------- Vérifier la date -------------------------
        IF(Vspec.DateS < SYSDATE ) THEN
            RAISE_APPLICATION_ERROR(-20106,'Vous ne pouvez pas modifier ni ajouter les rubriques associées aux spectacles déjà passés!!');
        ELSE
        ------------------- Vérifier l'heure de debut -------------------------
            IF (:NEW.H_DEBUTR <Vspec.H_DEBUT OR VH_FinS<=:NEW.H_DEBUTR) THEN 

                RAISE_APPLICATION_ERROR(-20106,'L''heure de début de cette rubrique est invalide! Elle doit etre entre:'||Vspec.H_DEBUT||'h et '||VH_FinS||'h !!');
        
        ------------------- Vérifier la durée ---------------------------------
            ELSIF (VH_FinS<VH_FinRub ) THEN
             RAISE_APPLICATION_ERROR(-20106,'La durée de cette rubrique est trop importante par rapport au spectacle associé !!!');
            END IF;
            
        END IF;

   END IF;
END;

/
---- Voir spectacle avec idSpec=2 ------
SELECT * FROM Spectacle WHERE idSpec=2;

--inserer une rubrique avec une h_debut inférieur à celle du spectacle--
INSERT INTO Rubrique VALUES(2,2,10,8,1,'imitation');

--inserer une rubrique avec une durée supérieure à celle du spectacle--
INSERT INTO Rubrique VALUES(2,2,10,12,3,'imitation');

/
CREATE OR REPLACE TRIGGER Trig_Rubrique_Art
BEFORE INSERT OR UPDATE OF idArt
ON Rubrique
FOR EACH ROW 
DECLARE
    VnbS NUMERIC;
BEGIN
    
    SELECT COUNT(idRub) INTO VnbS FROM Rubrique WHERE  idArt=:NEW.idArt 
    ---- Meme date ------
    AND idSpec=:NEW.idSpec
    ---- H_debut et duree qui chevauchent -----
    AND ( ( :NEW.H_debutR<=H_debutR AND H_debutR < :NEW.H_debutR+:NEW.dureeRub) OR
           (:NEW.H_debutR<H_debutR+dureeRub AND H_debutR+dureeRub <= :NEW.H_debutR+:NEW.dureeRub ) OR 
           ( H_debutR <=:NEW.H_debutR AND :NEW.H_debutR+:NEW.dureeRub <=H_debutR+dureeRub ) );

    IF( VnbS>0) THEN 
        RAISE_APPLICATION_ERROR(-20107,'L''Artiste choisi est non disponible !!');
    END IF;
    
END;
/

------------- Voir les rubriques artiste id=10----------
SELECT * FROM Rubrique WHERE idArt=10;

--- Inserer une rubrique avec un artiste non disponible ------
INSERT INTO Rubrique VALUES(2,2,10,12,1,'imitation');
/
CREATE OR REPLACE TRIGGER Trig_Rubrique_Sup
BEFORE DELETE ON Rubrique
FOR EACH ROW 
DECLARE
 PRAGMA AUTONOMOUS_TRANSACTION;
 Vnbr NUMERIC;
BEGIN
    -----chercher des rubriques qui ont dateS < SYSDATE---------------
    SELECT COUNT(R.idRub) INTO Vnbr FROM Rubrique R, Spectacle S 
    WHERE R.idSpec=S.idSpec AND R.idRub=:NEW.idRub AND S.dateS<SYSDATE;

    IF(Vnbr >0) THEN
       RAISE_APPLICATION_ERROR(-20108,'IMPOSSIBLE DE SUPPRIMER UNE RUBRIQUE DEJA PASSEE !!!');
    END IF;
END;
/
INSERT INTO SPECTACLE VALUES(3,'Tour de l''humour','20-12-2000',8,3,200,3);

/
-------------------------------------------- TABLE BILLET ------------------------------------------------
/
CREATE OR REPLACE TRIGGER Trig_Billet_prix_categ
BEFORE INSERT OR UPDATE OF prix
ON Billet
FOR EACH ROW
DECLARE
             VmaxNORMAL NUMERIC :=100 ;
     VmaxSILVER NUMERIC :=200 ;
     VGold Billet.Categorie%TYPE :='Gold' ;
     VSilver Billet.Categorie%TYPE :='silver' ;
     VNormal Billet.Categorie%TYPE :='normale' ;
BEGIN
	IF(:NEW.categorie=VGold AND :NEW.prix <=VmaxSILVER) THEN
	      RAISE_APPLICATION_ERROR(-20109,'Le prix pour cette  catégorie doit être supérieur à '||VmaxSILVER) ;

	ELSIF(:NEW.categorie=VSilver AND(:NEW.prix<= VmaxNORMAL OR :NEW.prix> VmaxSILVER)) THEN
RAISE_APPLICATION_ERROR(-20109,'Le prix pour cette  catégorie doit être entre à '|| VmaxNORMAL ||' et  '||VmaxSILVER) ;

	ELSIF(:NEW.categorie=VNormal AND :NEW.prix> VmaxNORMAL) THEN
	     RAISE_APPLICATION_ERROR(-20109,'Le prix pour cette  catégorie doit être inférieur ou égal à '||VmaxNORMAL) ;
	END IF;
END;
/
------------Ajouter silver prix 250 -------------
INSERT INTO Billet VALUES(1,'silver',250,2,'Non');


/
-------------------------------------------- NETOYER TABLES ------------------------------------------------
DROP TRIGGER TRI_RUBRIQUE_SUP;
DROP TRIGGER TRI_RUBRIQUE_SUP;
DROP TRIGGER TRIG_SPEC_DISPOLIEU;
DROP TRIGGER Tri_Rubrique_Art;
DROP TABLE SPECTACLE;
DROP TABLE RUBRIQUE;
DROP TABLE BILLET;

DELETE FROM RUBRIQUE;
DELETE FROM BILLET;
DELETE FROM SPECTACLE;
DELETE FROM Artiste;
DELETE FROM Lieu WHERE idLieu=100;

COMMIT;
