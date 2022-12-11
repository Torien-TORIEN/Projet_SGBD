CREATE OR REPLACE PACKAGE Pa_GestionSpectacle AS

PROCEDURE P_ajouter_Spectacle(idS Spectacle.idSpec%TYPE,titreS Spectacle.Titre%TYPE
,datS Spectacle.dateS%TYPE,heureD Spectacle.H_debut%TYPE,duree Spectacle.durees%TYPE
,NbrSpec spectacle.nbrspectateur%TYPE,idL Spectacle.idLieu%TYPE ) ;

PROCEDURE P_annuler_Spectacle(id Spectacle.idSpec%TYPE);

PROCEDURE P_modifier_Spectacle(id Spectacle.idSpec%TYPE,titreS Spectacle.Titre%TYPE
,datS Spectacle.dateS%TYPE,heureD Spectacle.H_debut%TYPE,duree Spectacle.durees%TYPE
,NbrSpec spectacle.nbrspectateur%TYPE,idL Spectacle.idLieu%TYPE );

PROCEDURE P_chercher_Spectacle_id(id Spectacle.idSpec%TYPE);
PROCEDURE P_chercher_Spectacle_titre(titreS Spectacle.Titre%TYPE);

PROCEDURE P_ajouter_Rubrique(id Rubrique.idRub%TYPE,idS Rubrique.idSpec%TYPE,idA Rubrique.idArt%TYPE
,heure Rubrique.H_debutR%TYPE,duree Rubrique.dureeRub%TYPE,typ Rubrique.type%TYPE);

PROCEDURE P_modifier_Rubrique(id Rubrique.idRub%TYPE,Art Rubrique.idArt%TYPE
,duree Rubrique.dureeRub%TYPE,heure Rubrique.H_DebutR%TYPE);

PROCEDURE P_supprimer_Rubrique(id Rubrique.idRub%TYPE);
PROCEDURE P_chercher_Rubrique_id(id Rubrique.idRub%TYPE);
PROCEDURE P_chercher_Rubrique_idSpec(idS spectacle.idspec%TYPE);
PROCEDURE P_chercher_Rubrique_nomArt(nom Artiste.nomArt%TYPE);
PROCEDURE P_chercher_Rubrique_idS_nomA(idS spectacle.idspec%TYPE,nom Artiste.nomArt%TYPE);
PROCEDURE P_chercher_Rubrique(id Rubrique.idRub%TYPE ,idS spectacle.idspec%TYPE,nom Artiste.nomArt%TYPE);

END;
/

CREATE OR REPLACE PACKAGE BODY Pa_GestionSpectacle AS
--**************************************************************************************************--
--------------------------------------- AJOUTER   SPECTACLE -------------------------------------------

PROCEDURE P_ajouter_Spectacle(idS Spectacle.idSpec%TYPE,titreS Spectacle.Titre%TYPE
,datS Spectacle.dateS%TYPE,heureD Spectacle.H_debut%TYPE,duree Spectacle.durees%TYPE
,NbrSpec spectacle.nbrspectateur%TYPE,idL Spectacle.idLieu%TYPE ) IS

VLieu Lieu.idLieu%TYPE;
id Spectacle.idSpec%TYPE:=idS;
BEGIN
    IF(idS IS NULL) THEN id:=Seq_idSpec.NEXTVAL; END IF;
    ------ Verifier si le lieu existe et non supprimÃ© logiquement -----
    SELECT idLieu INTO VLieu FROM Lieu WHERE idLieu=idL AND Est_Supprime='Non';
    ---- DisponibilitÃ© du lieu est gÃ©rÃ© par Trigger Trig_Spec_DispoLieu --------
    INSERT INTO Spectacle VALUES(id,titreS,datS,heureD,duree,NbrSpec,idL);
    COMMIT;
    Afficher('AJOUT AVEC SUCCES !!');
    ------------ Lieu non trouvÃ© --------------------
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
    Afficher('Ce lieu n''existe pas ou SupprimÃ© logiquement !!!');
    
END;


--------------------------------------- ANNULLER  SPECTACLE -------------------------------------------

PROCEDURE P_annuler_Spectacle(id Spectacle.idSpec%TYPE) IS 
Vnbr NUMERIC;
Vdate Spectacle.DateS%TYPE;
BEGIN
    SELECT COUNT(idSpec) INTO Vnbr FROM SPECTACLE WHERE idSpec=id;
    IF(Vnbr>0) THEN
        SELECT dateS INTO Vdate FROM SPECTACLE WHERE idSpec=id;
        IF(Vdate>SYSDATE) THEN
            UPDATE Spectacle SET DateS=NULL WHERE idSpec=id;
            COMMIT;
            Afficher('ANNULATION REUSSIE !!');
        ELSE
            Afficher('SPECTACLE DEJA PASSE , IMPOSSIBLE D''ANNULER !!');
        END IF;
    ELSE
        Afficher('CE SEPECTACLE N''EXISTE PAS !!');
    END IF;
END;


--------------------------------------- MODIFIER  SPECTACLE -------------------------------------------

PROCEDURE P_modifier_Spectacle(id Spectacle.idSpec%TYPE,titreS Spectacle.Titre%TYPE
,datS Spectacle.dateS%TYPE,heureD Spectacle.H_debut%TYPE,duree Spectacle.durees%TYPE
,NbrSpec spectacle.nbrspectateur%TYPE,idL Spectacle.idLieu%TYPE ) IS

Vnbr NUMERIC;

BEGIN
    IF(titreS IS NOT NULL)  THEN UPDATE Spectacle SET titre=titreS          WHERE idSpec=id; END IF;
    IF(datS IS NOT NULL)    THEN UPDATE Spectacle SET dateS=datS            WHERE idSpec=id; END IF;
    IF(NbrSpec IS NOT NULL) THEN UPDATE Spectacle SET NbRSpectateur=NbrSpec WHERE idSpec=id; END IF;
    
    ------ Disponibilité de lieu sera vérifiée par TRIGGER Trig_Spec_LieuDispo ------
    IF(idL IS NOT NULL)     THEN UPDATE Spectacle SET idLieu=idL            WHERE idSpec=id; END IF;
    
    ------- Mise à jour de H_debutR sera faite par TRIGGER Trig_Spec_Tri_Spec_MAJ_Hdebut -----
    IF(HeureD IS NOT NULL)  THEN UPDATE Spectacle SET H_Debut=HeureD        WHERE idSpec=id; END IF;
    
    ------Mise à jour de DureeRub sera faite par TRIGGER Tri_Spec_MAJ_DureeS ----------
    IF(duree IS NOT NULL)   THEN UPDATE Spectacle SET DureeS=duree          WHERE idSpec=id; END IF;
    
    Vnbr:=SQL%ROWCOUNT;
    COMMIT;
    IF(Vnbr>0) THEN
        Afficher('MISE A JOUR AVEC SUCCES !!');
    ELSE
        Afficher('AUCUNE  MISE A JOUR A ETE FAITE !!!');
    END IF;

END;


--------------------------------------- SUPPRIMER SPECTACLE -------------------------------------------

--------------------------------------- CHERCHER  SPECTACLE -------------------------------------------
                      ------------------ PAR IDSPEC -----------------

PROCEDURE P_chercher_Spectacle_id(id Spectacle.idSpec%TYPE) IS
VSpec Spectacle%ROWTYPE;
BEGIN
    SELECT * INTO VSpec FROM Spectacle WHERE idSpec=id;
    Afficher('SPECTACLE :: '||VSpec.idSpec||' '||VSpec.titre||' DU :'||VSpec.dateS
    ||' A '||VSpec.H_debut||'H '||' || Nbr° Spectateurs :'||VSpec.NbrSpectateur|| ' || idLieu :'||VSpec.idLieu );
    
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
    Afficher('Aucun Spectacle Trouvé avec id ='||id);
END;

                      ------------------ PAR TITRE ------------------

PROCEDURE P_chercher_Spectacle_titre(titreS Spectacle.Titre%TYPE) IS
CURSOR Cur_Spec IS SELECT * FROM SPECTACLE WHERE UPPER(titre)=UPPER(titreS);
VSpec Cur_Spec%ROWTYPE;
Vnbr NUMERIC;
BEGIN
    SELECT COUNT(idSpec) INTO Vnbr FROM SPECTACLE WHERE UPPER(titre)=UPPER(titreS);
    IF(Vnbr>0) THEN
        Afficher('LE(S) SPECTACLE(S) AVEC Titre = '||titreS||' :');
        OPEN Cur_Spec;
        LOOP
            FETCH Cur_Spec INTO VSpec;
            EXIT WHEN Cur_Spec%NOTFOUND OR Cur_Spec%NOTFOUND  IS NULL;
            AfficherB('SPECTACLE :: '||VSpec.idSpec||' '||VSpec.titre||' DU :'||VSpec.dateS||' A '||
            VSpec.H_debut||'H '||' || Nbr° Spectateurs :'||VSpec.NbrSpectateur|| ' || idLieu :'||VSpec.idLieu );
        END LOOP;
    ELSE
        Afficher('Aucun Spectacle Trouvé avec le titre ='||titreS);
    END IF;
END;

--**************************************************************************************************--
--------------------------------------- AJOUTER RUBRIQUE  -------------------------------------------

PROCEDURE P_ajouter_Rubrique(id Rubrique.idRub%TYPE,idS Rubrique.idSpec%TYPE,idA Rubrique.idArt%TYPE
,heure Rubrique.H_debutR%TYPE,duree Rubrique.dureeRub%TYPE,typ Rubrique.type%TYPE) IS

Vid Rubrique.idRub%TYPE:=id;
BEGIN
    IF(id IS NULL) THEN Vid:=Seq_idRub.NEXTVAL; END IF;
    ----- Les controles sont faits par les TRIGGERS : ------
    INSERT INTO Rubrique VALUES(Vid,idS,idA,heure,duree,typ);
    COMMIT;
    Afficher('AJOUT AVEC SUCCES !!!');
END;


--------------------------------------- MODIFIER RUBRIQUE  -------------------------------------------

PROCEDURE P_modifier_Rubrique(id Rubrique.idRub%TYPE,Art Rubrique.idArt%TYPE
,duree Rubrique.dureeRub%TYPE,heure Rubrique.H_DebutR%TYPE) IS
Vnbr NUMERIC;
BEGIN
    IF(Art IS NOT NULL)   THEN UPDATE Rubrique SET idArt=Art      WHERE idRub=id; END IF;
    IF(duree IS NOT NULL) THEN UPDATE Rubrique SET dureeRub=duree WHERE idRub=id; END IF;
    IF(heure IS NOT NULL) THEN UPDATE Rubrique SET H_DebutR=heure WHERE idRub=id; END IF;
    Vnbr:=SQL%ROWCOUNT;
    COMMIT;
    IF (Vnbr>0) THEN
        Afficher('MISE A JOUR REUSSIE !!!');
    ELSE
        Afficher('AUCUNE MISE A JOUR EST EFFECTUEE !!!');
    END IF;
END;

--------------------------------------- SUPPRIMER RUBRIQUE -------------------------------------------

PROCEDURE P_supprimer_Rubrique(id Rubrique.idRub%TYPE) IS
Vdate Spectacle.dateS%TYPE;
BEGIN
    SELECT S.dateS INTO Vdate FROM Rubrique R, Spectacle S 
    WHERE R.idSpec=S.idSpec AND R.idRub=id;
    
    IF(Vdate>SYSDATE) THEN
        DELETE FROM Rubrique WHERE idRub=id;
        COMMIT;
        Afficher('SUPPRESSION AVEC SUCCES !!!');
    ELSE
        Afficher('IMPOSSIBLE DE SUPPRIMER UNE RUBRIQUE DEJA PASSEE !!!');
    END IF;
    
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
    Afficher('Cette rubrique n''existe pas !!!');
END;

--------------------------------------- CHERCHER RUBRIQUE -------------------------------------------
                      ------------------ PAR IDRUB ------------------

PROCEDURE P_chercher_Rubrique_id(id Rubrique.idRub%TYPE) IS
Vtitre Spectacle.titre%TYPE;
Vdate Spectacle.dateS%TYPE;
VnomA Artiste.nomArt%TYPE;
VpenomA Artiste.prenomArt%TYPE;
Vheure Rubrique.h_debutR%TYPE;
Vdure Rubrique.dureeRub%TYPE;
Vtype Rubrique.Type%TYPE;
BEGIN
    SELECT H_debutR,dureeRub,Type,S.titre,S.dateS,A.nomArt,A.prenomArt INTO Vheure,Vdure,Vtype,Vtitre,Vdate,VnomA,VpenomA
    FROM Rubrique R, Spectacle S, Artiste A
    WHERE R.idSpec=S.idSpec AND R.idArt=A.idArt AND idRub=id;
    
   Afficher('RUBRIQUE ::  N° '||id||' de  '||Vtitre||' LE :'||Vdate
    ||' A '||Vheure||'H '||' || Type :'||Vtype|| ' || Artiste :'||VnomA||' '||VpenomA);
    
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
    Afficher('Aucune Rubrique Trouvée avec id ='||id);
END;
                      
                      
                      ------------------ PAR IDSPEC -----------------

PROCEDURE P_chercher_Rubrique_idSpec(idS spectacle.idspec%TYPE) IS
CURSOR Cur_Rub IS SELECT R.idRub,H_debutR,dureeRub,Type,S.titre,S.dateS,A.nomArt,A.prenomArt
FROM Rubrique R, Spectacle S, Artiste A WHERE R.idSpec=S.idSpec AND R.idArt=A.idArt AND R.idSpec=idS;

VCur Cur_Rub%ROWTYPE;
Vnbr NUMERIC;
BEGIN
    SELECT COUNT(R.idRub) INTO Vnbr FROM Rubrique R, Spectacle S, Artiste A 
    WHERE R.idSpec=S.idSpec AND R.idArt=A.idArt AND R.idSpec=idS;
    IF(Vnbr>0) THEN
        OPEN Cur_Rub;
        Afficher('RESULTAT DE LA RECHERCHE :');
        LOOP
            FETCH Cur_Rub INTO VCur;
            EXIT WHEN Cur_Rub%NOTFOUND OR Cur_Rub%NOTFOUND IS NULL;
            AfficherM('RUBRIQUE :: N°'||VCur.idRub||' de  '||VCur.titre||' LE :'||VCur.dateS||' A '||VCur.H_debutR
            ||'H '||' || Type :'||VCur.type|| ' || Artiste :'||VCur.nomArt||' '||VCur.prenomArt);
        END LOOP;
        AfficherB('');
        CLOSE Cur_Rub;
    ELSE
        Afficher('Aucun Rubrique trouvée !!!');
    END IF;
    
END;
                      
                      
                      ------------------ PAR NomArt -----------------

PROCEDURE P_chercher_Rubrique_nomArt(nom Artiste.nomArt%TYPE) IS
CURSOR Cur_Rub IS SELECT R.idRub,H_debutR,dureeRub,Type,S.titre,S.dateS,A.nomArt,A.prenomArt
FROM Rubrique R, Spectacle S, Artiste A 
WHERE R.idSpec=S.idSpec AND R.idArt=A.idArt AND UPPER(A.nomArt)=UPPER(nom);

VCur Cur_Rub%ROWTYPE;
Vnbr NUMERIC;
BEGIN
    SELECT COUNT(R.idRub) INTO Vnbr FROM Rubrique R, Spectacle S, Artiste A 
    WHERE R.idSpec=S.idSpec AND R.idArt=A.idArt AND UPPER(A.nomArt)=UPPER(nom);

    IF(Vnbr>0) THEN
        OPEN Cur_Rub;
        Afficher('RESULTAT DE LA RECHERCHE :');
        LOOP
            FETCH Cur_Rub INTO VCur;
            EXIT WHEN Cur_Rub%NOTFOUND OR Cur_Rub%NOTFOUND IS NULL;
            AfficherM('RUBRIQUE :: N°'||VCur.idRub||' de  '||VCur.titre||' LE :'||VCur.dateS||' A '||VCur.H_debutR
            ||'H '||' || Type :'||VCur.type|| ' || Artiste :'||VCur.nomArt||' '||VCur.prenomArt);
        END LOOP;
        AfficherB('');
        CLOSE Cur_Rub;
    ELSE
        Afficher('Aucun Rubrique trouvée !!!');
    END IF;
    
END;
                      
                      
                      ------------------ PAR IdSpec & NomArt --------

PROCEDURE P_chercher_Rubrique_idS_nomA(idS spectacle.idspec%TYPE,nom Artiste.nomArt%TYPE) IS
CURSOR Cur_Rub IS SELECT R.idRub,H_debutR,dureeRub,Type,S.titre,S.dateS,A.nomArt,A.prenomArt
FROM Rubrique R, Spectacle S, Artiste A 
WHERE R.idSpec=S.idSpec AND R.idArt=A.idArt AND R.idSpec=idS AND UPPER(A.nomArt)=UPPER(nom) ;

VCur Cur_Rub%ROWTYPE;
Vnbr NUMERIC;
BEGIN
    SELECT COUNT(R.idRub) INTO Vnbr FROM Rubrique R, Spectacle S, Artiste A 
    WHERE R.idSpec=S.idSpec AND R.idArt=A.idArt AND R.idSpec=idS AND UPPER(A.nomArt)=UPPER(nom);
    
    IF(Vnbr>0) THEN
        OPEN Cur_Rub;
        Afficher('RESULTAT DE LA RECHERCHE :');
        LOOP
            FETCH Cur_Rub INTO VCur;
            EXIT WHEN Cur_Rub%NOTFOUND OR Cur_Rub%NOTFOUND IS NULL;
            AfficherM('RUBRIQUE :: N°'||VCur.idRub||' de  '||VCur.titre||' LE :'||VCur.dateS||' A '||VCur.H_debutR
            ||'H '||' || Type :'||VCur.type|| ' || Artiste :'||VCur.nomArt||' '||VCur.prenomArt);
        END LOOP;
        AfficherB('');
        CLOSE Cur_Rub;
    ELSE
        Afficher('Aucun Rubrique trouvée !!!');
    END IF;
    
END;
                      
                      
                      ------------------ GLOBAL ---------------------

PROCEDURE P_chercher_Rubrique(id Rubrique.idRub%TYPE ,idS spectacle.idspec%TYPE,nom Artiste.nomArt%TYPE) IS
BEGIN
    IF( id IS NOT NULL ) THEN 
        P_chercher_Rubrique_id(id);
    ELSIF( nom IS NOT NULL AND idS IS NOT NULL ) THEN 
        P_chercher_Rubrique_idS_nomA(idS,nom);
    ELSIF( nom IS NOT NULL AND idS IS  NULL ) THEN 
        P_chercher_Rubrique_nomArt(nom);
    ELSIF( nom IS  NULL AND idS IS NOT NULL ) THEN
        P_chercher_Rubrique_idSpec(idS);
    ELSE
        Afficher('Toutes les paramètres sont nuls !!');
    END IF;
END;



--**************************************************************************************************--
------------------------------------- END OF PACKAGE BODY-------------------------------------------

END;
/
COMMIT;