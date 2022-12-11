
CREATE OR REPLACE PACKAGE Pa_GestionLieu AS

PROCEDURE P_ajouter_lieu(idL Lieu.idLieu%TYPE, nom Lieu.NomLieu%TYPE, adresseL Lieu.Adresse%TYPE, 
capac Lieu.capacite%TYPE);
PROCEDURE P_modifier_lieu(id Lieu.idLieu%TYPE, nom Lieu.NomLieu%TYPE, capaciteL Lieu.capacite%TYPE);
PROCEDURE P_supprimer_lieu(id Lieu.idLieu%TYPE);
PROCEDURE P_chercher_lieu_id(id Lieu.idLieu%TYPE);
PROCEDURE P_cherecher_lieu_nom(nom Lieu.NomLieu%TYPE);
PROCEDURE P_cherecher_lieu_capacite(CapaciteL Lieu.Capacite%TYPE);
PROCEDURE P_cherecher_lieu_ville(ville Lieu.adresse%TYPE);
PROCEDURE P_cherecher_lieu_nom_ville(nom Lieu.NomLieu%TYPE,ville Lieu.adresse%TYPE);
PROCEDURE P_cherecher_lieu_ville_capac(ville Lieu.adresse%TYPE,CapaciteL Lieu.capacite%TYPE);
PROCEDURE P_cherecher_lieu_nom_capac(nom Lieu.NomLieu%TYPE,CapaciteL Lieu.capacite%TYPE);
PROCEDURE P_cherecher_lieu_nom_ville_cap(nom Lieu.NomLieu%TYPE,ville Lieu.adresse%TYPE,Cap Lieu.capacite%TYPE);
PROCEDURE P_cherecher_lieu(nom Lieu.NomLieu%TYPE,ville Lieu.adresse%TYPE,Cap Lieu.capacite%TYPE);

END;

/
CREATE OR REPLACE PACKAGE BODY Pa_GestionLieu AS
-----------------------------------------AJOUTER--------------------------------------------

PROCEDURE P_ajouter_lieu(idL Lieu.idLieu%TYPE, nom Lieu.NomLieu%TYPE, adresseL Lieu.Adresse%TYPE, capac Lieu.capacite%TYPE) IS

VidLieu lieu.idlieu%TYPE;
Vetat Lieu.Est_Supprime%TYPE;
VNbrL NUMERIC;
Msg VARCHAR2(100);
id Lieu.idLieu%TYPE:=idL;
BEGIN
    IF(idL IS NULL) THEN
        id:=Seq_idLieu.NEXTVAL;
    END IF;
	------------- verifier si ce lieu a été supprimé logiquement -----------
	SELECT COUNT(idLieu) INTO VNbrL FROM LIEU WHERE idLieu=id;
	IF( VNbrL > 0) THEN
        SELECT idLieu,est_supprime INTO VidLieu,Vetat FROM LIEU WHERE idLieu=id;
        IF(Vetat='Oui') THEN
            UPDATE Lieu SET est_supprime='Non' WHERE idLieu=id;
            Msg:='Un lieu est ajouté logiquement avec success !';
        ELSE
            Msg:='Ce lieu existe déjà !!!';
        END IF;
	ELSE
		INSERT INTO Lieu VALUES(id, nom, adresseL, capac,'Non');
        Msg:='Un lieu est ajouté avec success !';
	END IF;
	COMMIT;
    afficher(Msg);
END ;

-----------------------------------------MODIFIER-------------------------------------------

PROCEDURE P_modifier_lieu(id Lieu.idLieu%TYPE, nom Lieu.NomLieu%TYPE, capaciteL Lieu.capacite%TYPE) IS
Vnbr NUMERIC:=0;
Msg VARCHAR2(100);
BEGIN
	IF (nom IS NOT NULL  AND capaciteL IS NOT NULL) THEN
		UPDATE Lieu SET NomLieu=nom , capacite = capaciteL WHERE idLieu=id;
        Msg:='Modification de nom et de capacité  réussie !!!';
	ELSIF (nom IS NOT NULL AND capaciteL IS NULL) THEN 
		UPDATE Lieu SET NomLieu=nom WHERE idLieu=id;
        Msg:='Modification de nom réussie !!!';
	ELSIF (nom IS NULL AND capaciteL IS NOT NULL) THEN 
		UPDATE Lieu SET capacite = capaciteL WHERE idLieu=id;
        Msg:='Modification de la capacité réussie !!!';
	END IF;
    Vnbr:=SQL%ROWCOUNT;
	COMMIT;
    IF (Vnbr>0) THEN
        Afficher(Msg);
    ELSE
        Afficher('Aucune ligne est modifiée !!!');
    END IF;
END;

----------------------------------------SUPPRIMER-------------------------------------------

PROCEDURE P_supprimer_lieu(id Lieu.idLieu%TYPE) IS 
VnbIdLieu NUMBER;
VnbrSpec NUMBER;
VnbLSup NUMBER;
Msg VARCHAR2(100);
BEGIN
    ------- Verifier si le lieu existe ------------------
    SELECT COUNT(idLieu) INTO VnbIdLieu FROM LIEU WHERE idLieu=id;
    IF(VnbIdLieu>0) THEN
    
        ------- chercher spectacle associé a ce lieu ------------------
        SELECT COUNT(idSpec) INTO VnbrSpec FROM Spectacle WHERE idLieu=id;
        IF (VnbrSpec > 0 ) THEN
            UPDATE Lieu SET Est_Supprime='Oui' WHERE idLieu=id;
            Msg:='SUPPRESSION LOGIQUE EFFECTUEE !!';
        ELSE
            DELETE FROM Lieu WHERE idLieu=id;
            Msg:='SUPPRESSION PHYSIQUE AVEC SUCCES !!';
        END IF;
        COMMIT;
        
    ELSE
        Msg:='Aucun lieu trouvé avec id='||id;
    END IF;
	Afficher(Msg);
END;

---------------------------------------CHERCHER---------------------------------------------

				------------PAR ID --------------------------

PROCEDURE P_chercher_lieu_id(id Lieu.idLieu%TYPE) IS
VLieu Lieu%ROWTYPE;
BEGIN
    SELECT * INTO VLieu FROM Lieu WHERE idLieu=id AND Est_supprime='Non';
    Afficher('Lieu ::'||VLieu.idLieu||'  :'||VLieu.NomLieu||'| ADRESSE :'||VLieu.Adresse||
    ' | CAPACITE :'||VLieu.capacite);
    EXCEPTION 
    WHEN NO_DATA_FOUND THEN
        Afficher('Aucun lieu Correspondant !!');
END P_chercher_lieu_id;


				------------PAR NOM -------------------------

PROCEDURE P_cherecher_lieu_nom(nom Lieu.NomLieu%TYPE) IS
CURSOR Cur_Lieux IS SELECT * FROM Lieu WHERE Est_supprime='Non' AND UPPER(NomLieu)LIKE ('%'||UPPER(nom)||'%');
VLieu Cur_Lieux%ROWTYPE;
VnbrL NUMERIC;
BEGIN
    SELECT COUNT(idLieu)INTO VnbrL FROM Lieu WHERE Est_supprime='Non' AND UPPER(NomLieu)LIKE (UPPER(nom)||'%');
    IF(VnbrL > 0) THEN
        Afficher('LIEUX TROUVES :');
        OPEN Cur_Lieux;
        LOOP
            FETCH Cur_Lieux INTO VLieu;
            EXIT WHEN Cur_Lieux%NOTFOUND ;
            AfficherM('Lieu ::'||VLieu.idLieu||'  :'||VLieu.NomLieu||'| ADRESSE :'||VLieu.Adresse
            ||' | CAPACITE :'||VLieu.capacite);
        END LOOP;
        CLOSE Cur_Lieux;
        AfficherB('');
    ELSE
        Afficher('Aucun Lieu Correspondant !');
    END IF;
END ;

				------------PAR CAPACITE --------------------

PROCEDURE P_cherecher_lieu_capacite(CapaciteL Lieu.Capacite%TYPE) IS
CURSOR Cur_Lieux IS SELECT * FROM Lieu WHERE Est_supprime='Non' AND capacite=CapaciteL ;
VLieu Cur_Lieux%ROWTYPE;
VnbrL NUMERIC;
BEGIN
    SELECT COUNT(idLieu)INTO VnbrL FROM Lieu WHERE Est_supprime='Non' AND capacite=CapaciteL ;
    IF(VnbrL > 0) THEN
        Afficher('LIEUX TROUVES :');
        OPEN Cur_Lieux;
        LOOP
            FETCH Cur_Lieux INTO VLieu;
            EXIT WHEN Cur_Lieux%NOTFOUND ;
            AfficherM('Lieu ::'||VLieu.idLieu||'  :'||VLieu.NomLieu||'| ADRESSE :'||VLieu.Adresse
            ||' | CAPACITE :'||VLieu.capacite);
        END LOOP;
        CLOSE Cur_Lieux;
        AfficherB('');
    ELSE
        Afficher('Aucun Lieu Correspondant !');
    END IF;
END ;

				------------PAR VILLE -----------------------

PROCEDURE P_cherecher_lieu_ville(ville Lieu.adresse%TYPE) IS
CURSOR Cur_Lieux IS SELECT * FROM Lieu 
WHERE Est_supprime='Non' AND( UPPER(adresse)LIKE ('%-%'||UPPER(ville)||'%-%') 
OR UPPER(adresse)LIKE ('%, '||UPPER(ville)||'%,%') OR UPPER(adresse)LIKE ('%'||UPPER(ville)) );
VLieu Cur_Lieux%ROWTYPE;
VnbrL NUMERIC;
BEGIN
    SELECT COUNT(idLieu)INTO VnbrL FROM Lieu 
    WHERE Est_supprime='Non' AND( UPPER(adresse)LIKE ('%-%'||UPPER(ville)||'%-%') 
    OR UPPER(adresse)LIKE ('%, '||UPPER(ville)||'%,%') OR UPPER(adresse)LIKE ('%'||UPPER(ville)) );
    IF(VnbrL > 0) THEN
        Afficher('LIEUX TROUVES :');
        OPEN Cur_Lieux;
        LOOP
            FETCH Cur_Lieux INTO VLieu;
            EXIT WHEN Cur_Lieux%NOTFOUND ;
            AfficherM('Lieu ::'||VLieu.idLieu||'  :'||VLieu.NomLieu||'| ADRESSE :'||VLieu.Adresse
            ||' | CAPACITE :'||VLieu.capacite);
        END LOOP;
        CLOSE Cur_Lieux;
        AfficherB('');
    ELSE
        Afficher('Aucun Lieu Correspondant !');
    END IF;
END ;

				------------PAR NOM & VILLE -----------------

PROCEDURE P_cherecher_lieu_nom_ville(nom Lieu.NomLieu%TYPE,ville Lieu.adresse%TYPE) IS

CURSOR Cur_Lieux IS SELECT * FROM Lieu 
WHERE Est_supprime='Non' AND( UPPER(adresse)LIKE ('%-%'||UPPER(ville)||'%-%') 
OR UPPER(adresse)LIKE ('%, '||UPPER(ville)||'%,%') OR UPPER(adresse)LIKE ('%'||UPPER(ville)) )
AND UPPER(NomLieu)LIKE ('%'||UPPER(nom)||'%');

VLieu Cur_Lieux%ROWTYPE;
VnbrL NUMERIC;
BEGIN
    SELECT COUNT(idLieu)INTO VnbrL FROM Lieu 
    WHERE Est_supprime='Non' AND( UPPER(adresse)LIKE ('%-%'||UPPER(ville)||'%-%') 
    OR UPPER(adresse)LIKE ('%, '||UPPER(ville)||'%,%') OR UPPER(adresse)LIKE ('%'||UPPER(ville)) )
    AND UPPER(NomLieu)LIKE ('%'||UPPER(nom)||'%');
    
    IF(VnbrL > 0) THEN
        Afficher('LIEUX TROUVES :');
        OPEN Cur_Lieux;
        LOOP
            FETCH Cur_Lieux INTO VLieu;
            EXIT WHEN Cur_Lieux%NOTFOUND ;
            AfficherM('Lieu ::'||VLieu.idLieu||'  :'||VLieu.NomLieu||'| ADRESSE :'||VLieu.Adresse
            ||' | CAPACITE :'||VLieu.capacite);
        END LOOP;
        CLOSE Cur_Lieux;
        AfficherB('');
    ELSE
        Afficher('Aucun Lieu Correspondant !');
    END IF;
END ;

				------------PAR NOM & CAPACITE --------------

PROCEDURE P_cherecher_lieu_nom_capac(nom Lieu.NomLieu%TYPE,CapaciteL Lieu.capacite%TYPE) IS
CURSOR Cur_Lieux IS SELECT * FROM Lieu WHERE Est_supprime='Non' 
AND capacite=CapaciteL AND UPPER(NomLieu)LIKE ('%'||UPPER(nom)||'%');

VLieu Cur_Lieux%ROWTYPE;
VnbrL NUMERIC;
BEGIN
    SELECT COUNT(idLieu)INTO VnbrL FROM Lieu WHERE Est_supprime='Non' 
    AND capacite=CapaciteL AND UPPER(NomLieu)LIKE (UPPER(nom)||'%');
    IF(VnbrL > 0) THEN
        Afficher('LIEUX TROUVES :');
        OPEN Cur_Lieux;
        LOOP
            FETCH Cur_Lieux INTO VLieu;
            EXIT WHEN Cur_Lieux%NOTFOUND ;
            AfficherM('Lieu ::'||VLieu.idLieu||'  :'||VLieu.NomLieu||'| ADRESSE :'||VLieu.Adresse
            ||' | CAPACITE :'||VLieu.capacite);
        END LOOP;
        CLOSE Cur_Lieux;
        AfficherB('');
    ELSE
        Afficher('Aucun Lieu Correspondant !');
    END IF;
END ;


				------------PAR VILLE & CAPACITE ------------

PROCEDURE P_cherecher_lieu_ville_capac(ville Lieu.adresse%TYPE,CapaciteL Lieu.capacite%TYPE) IS
CURSOR Cur_Lieux IS SELECT * FROM Lieu 
WHERE Est_supprime='Non' AND capacite=CapaciteL AND( UPPER(adresse)LIKE ('%-%'||UPPER(ville)||'%-%') 
OR UPPER(adresse)LIKE ('%, '||UPPER(ville)||'%,%') OR UPPER(adresse)LIKE ('%'||UPPER(ville)) );
VLieu Cur_Lieux%ROWTYPE;
VnbrL NUMERIC;
BEGIN
    SELECT COUNT(idLieu)INTO VnbrL FROM Lieu 
    WHERE Est_supprime='Non' AND capacite=CapaciteL AND( UPPER(adresse)LIKE ('%-%'||UPPER(ville)||'%-%') 
    OR UPPER(adresse)LIKE ('%, '||UPPER(ville)||'%,%') OR UPPER(adresse)LIKE ('%'||UPPER(ville)) );
    IF(VnbrL > 0) THEN
        Afficher('LIEUX TROUVES :');
        OPEN Cur_Lieux;
        LOOP
            FETCH Cur_Lieux INTO VLieu;
            EXIT WHEN Cur_Lieux%NOTFOUND ;
            AfficherM('Lieu ::'||VLieu.idLieu||'  :'||VLieu.NomLieu||'| ADRESSE :'||VLieu.Adresse
            ||' | CAPACITE :'||VLieu.capacite);
        END LOOP;
        CLOSE Cur_Lieux;
        AfficherB('');
    ELSE
        Afficher('Aucun Lieu Correspondant !');
    END IF;
END ;

				------------PAR NOM &VILLE & CAPACITE -------

PROCEDURE P_cherecher_lieu_nom_ville_cap(nom Lieu.NomLieu%TYPE,ville Lieu.adresse%TYPE,Cap Lieu.capacite%TYPE) IS

CURSOR Cur_Lieux IS SELECT * FROM Lieu 
WHERE Est_supprime='Non' AND capacite=Cap AND UPPER(NomLieu)LIKE ('%'||UPPER(nom)||'%')
AND( UPPER(adresse)LIKE ('%-%'||UPPER(ville)||'%-%') 
OR UPPER(adresse)LIKE ('%, '||UPPER(ville)||'%,%') OR UPPER(adresse)LIKE ('%'||UPPER(ville)) );

VLieu Cur_Lieux%ROWTYPE;
VnbrL NUMERIC;
BEGIN
    SELECT COUNT(idLieu)INTO VnbrL FROM Lieu 
    WHERE Est_supprime='Non' AND capacite=Cap AND UPPER(NomLieu)LIKE ('%'||UPPER(nom)||'%')
    AND( UPPER(adresse)LIKE ('%-%'||UPPER(ville)||'%-%') 
    OR UPPER(adresse)LIKE ('%, '||UPPER(ville)||'%,%') OR UPPER(adresse)LIKE ('%'||UPPER(ville)) );
    
    IF(VnbrL > 0) THEN
        Afficher('LIEUX TROUVES :');
        OPEN Cur_Lieux;
        LOOP
            FETCH Cur_Lieux INTO VLieu;
            EXIT WHEN Cur_Lieux%NOTFOUND ;
            AfficherM('Lieu ::'||VLieu.idLieu||'  :'||VLieu.NomLieu||'| ADRESSE :'||VLieu.Adresse
            ||' | CAPACITE :'||VLieu.capacite);
        END LOOP;
        CLOSE Cur_Lieux;
        AfficherB('');
    ELSE
        Afficher('Aucun Lieu Correspondant !');
    END IF;
END ;


				------------PAR GLOBAL ----------------------
PROCEDURE P_cherecher_lieu(nom Lieu.NomLieu%TYPE,ville Lieu.adresse%TYPE,Cap Lieu.capacite%TYPE) IS
BEGIN
    IF(nom IS NOT NULL AND ville IS NOT NULL AND Cap IS NOT NULL) THEN 
        ----- nom et ville et capacite-------
        P_cherecher_lieu_nom_ville_cap(nom,ville,Cap);
        
    ELSIF(nom IS NOT NULL AND ville IS NOT NULL AND Cap IS NULL) THEN
        ----- nom et ville -----------
        P_cherecher_lieu_nom_ville(nom,ville);
        
    ELSIF(nom IS NOT NULL AND ville IS NULL AND Cap IS NOT NULL) THEN
        ----- nom et capacite -------
        P_cherecher_lieu_nom_capac(nom,Cap);
        
    ELSIF(nom IS NULL AND ville IS NOT NULL AND Cap IS NOT NULL) THEN
        ----- ville et capacite-------
        P_cherecher_lieu_ville_capac(ville,Cap);
        
    ELSIF(nom IS NOT NULL AND ville IS NULL AND Cap IS NULL) THEN
        ---------- nom --------------
        P_cherecher_lieu_nom(nom);
        
    ELSIF(nom IS NULL AND ville IS NOT NULL AND Cap IS NULL) THEN
        -------- ville -------------
        P_cherecher_lieu_ville(ville);
    ELSIF(nom IS NULL AND ville IS NULL AND Cap IS NOT NULL) THEN
         ----- capacite-------
         P_cherecher_lieu_capacite(Cap);
    ELSE
        Afficher('Toutes les paramètres sont nulles');
    END IF;

END;


---------------------------------------END OF BODY PACKAGE---------------------------------------------
END;

/
********************************************************************* TEST *******************************************/
SET SERVEROUTPUT ON;
BEGIN
    Pa_GestionLieu.P_cherecher_lieu('EL TEATRO',NULL,NULL);
END;

