--------------- CLIENT--------------

CREATE SEQUENCE Seq_idClt
INCREMENT BY 10
START WITH 10;

--------------- ARTISTE--------------
CREATE SEQUENCE Seq_idArt
INCREMENT BY 10
START WITH 10;

--------------- LIEU --------------
CREATE SEQUENCE Seq_idLieu
START WITH 17;

--------------- SPECTACLE--------------
CREATE SEQUENCE Seq_idSpec
START WITH 1;

--------------- RUBRIQUE --------------
CREATE SEQUENCE Seq_idRub
START WITH 1;

--DROP SEQUENCE Seq_idArt;

COMMIT;