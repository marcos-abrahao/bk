//Retorna Nome do Usuario
USER FUNCTION BUSER(cUSER)
LOCAL cNUser := ""

   PswOrder(1) 
   PswSeek(cUser) 
   aUser  := PswRet(1)
   IF !EMPTY(aUser)
      cNUser := aUser[1,2]
   ENDIF   

RETURN cNUser