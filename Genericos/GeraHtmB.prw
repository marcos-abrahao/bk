#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

// Funcão para gerar texto Html

User Function GeraHtmB(aDet,cTitulo,aCabs,cPrw,cRodape,cEmail,cEmailCC)
Local cMsg := ""
Local _ni,_nJ
Local lCorNao := .T.
Local cPicN   := "@E 99999999.99"
Local cAlign  := ""
Default cPrw  := ""
Default cRodape := ""
Default cEmail := ""
Default cEmailCC := ""

cMsg += CabHtml(cPrw,cTitulo)  

cMsg += '<table width="100%" Align="center" border="0" cellspacing="0" cellpadding="0" bordercolor="#CCCCCC" >' 
cMsg += '<thead style="vertical-align: top; background-color: #9E0000; color: #FFFFFF; font-size: 9pt; line-height: 120%;">' + CRLF
For _nI := 1 TO LEN(aCabs)

   cAlign  :=	"text-align: left;"
   If Len(aDet) > 0
      If _ni <= LEN(aDet[1])
         xCampo := aDet[1,_ni]
                        
         If VALTYPE(xCampo) == "D" // Trata campos data
            cAlign := 'text-align: center;'
         ElseIf VALTYPE(xCampo) == "N" // Trata campos numericos
            cAlign := 'text-align: right;'
         Endif      
      EndIf
   EndIf

	cMsg += '<th style="padding: 5px 2px 5px 2px;font-family: Arial;'+cAlign+';"><b>'+ALLTRIM(aCabs[_nI])+'</b></th>' 
Next
cMsg += '</thead>' 

cMsg += '<tbody style="vertical-align: top; font-size: 8pt; line-height: 120%;">'
For _nJ := 1 TO LEN(aDet)

    If lCorNao   
       cMsg += '<tr>'
    Else   
       cMsg += '<tr style="background-color:#fdf1f1;">'
    EndIf   
    lCorNao := !lCorNao
	
    For _ni :=1 to LEN(aDet[_nj])
	
         xCampo := aDet[_nJ,_ni]
	            
         _uValor := ""
         cAlign  := "text-align: left;"
			            
         if VALTYPE(xCampo) == "D" // Trata campos data
            _uValor := dtoc(xCampo)
            cAlign := 'text-align: center;'
         elseif VALTYPE(xCampo) == "N" // Trata campos numericos
            _uValor := ALLTRIM(transform(xCampo,cPicN))
            cAlign := 'text-align: right'
         elseif VALTYPE(xCampo) == "C" // Trata campos caracter
            _uValor := ALLTRIM(xCampo)
         endif
            
         cMsg += '<td style="padding: 5px 2px 5px 2px;font-family: Arial; white-space: nowrap;'+cAlign+'">'+TRIM(_uValor)+'</td>'
	            
      Next _ni

      cMsg += '</tr>'
	
Next _nJ
cMsg += '</tbody>'

cMsg += FimHtml(cPrw,cRodape,cEmail,cEmailCC)

Return cMsg


Static Function CabHtml(cPrw,cTitulo)
Local cHtm  := ""
Local cLogo := ""
Local cUser := ""

If ValType(cUserName) == "U"
   cUser := "Admin"
Else
   cUser := cUserName
EndIf

cLogo := u_BKLogos()

cHtm += '<html lang="pt-BR" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:v="urn:schemas-microsoft-com:vml">' 

cHtm += '<head>' 
cHtm += '<meta http-equiv=Content-Type content="text/html; charset=iso-8859-1">' 
//cHtm += '<link rel=Edit-Time-Data href="./HistD_arquivos/editdata.mso">' 
cHtm += '<title>'+cTitulo+' - '+DTOC(date())+' '+TIME()+'</title>' 
cHtm += u_BkFavIco()
cHtm += '<style>' 
//cHtm += '.Normal{font-size:11.0pt;font-family:"Arial";}' 
//cHtm += '.F8A{font-size:8.0pt;font-family:"Arial"}' 
//cHtm += '.F10A{font-size:10.0pt;font-family:"Arial"}' 
cHtm += '</style>' 
cHtm += '</head>' 
cHtm += '<body bgcolor=#ffffff lang=PT-BR>' 

cHtm += '<table border=0 align="center" cellpadding=0 width="100%" style="center" >' 
cHtm += ' <tr>' 
cHtm += '  <td width=15%>' 
cHtm += '    <p align=center style="text-align:center">'+cLogo+'</p>' 
cHtm += '  </td>' 
cHtm += '  <td width=85% style="center">' 
cHtm += '    <p align=center style="text-align:center;font-size:16;"><b></b></p>' 
cHtm += '  </td>' 
cHtm += ' </tr>' 

cHtm += ' <tr>' 
cHtm += '  <td colspan="2">' 
cHtm += '    <p align=center style="text-align:center;font-size:16;"><b>'+cTitulo+'</b></p>' 
cHtm += '  </td>' 
cHtm += ' </tr>' 

cHtm += ' <tr>' 
cHtm += '  <td colspan="2">' 
cHtm += '    <p align=center style="text-align:center;font-size:10;"><b>'+TRIM(cPrw)+' '+DTOC(DATE())+' '+TIME()+' - '+cUser+'</b></p>' 
cHtm += '  </td>' 
cHtm += ' </tr>' 
cHtm += '</table>' 
cHtm += '<br>' 
Return cHtm



Static Function FimHtml(cPrw,cRodape,cEmail,cEmailCC)
Local cHtm        := ""

Default cPrw      := ""
Default cEmail    := ""
Default cEmailCC  := ""

cHtm += '</table>' 

cHtm += '<br>'

If !EMPTY(cRodape) 
	cHtm += '<p style="font-size:8.0pt;font-family: Arial;"><b>'+TRIM(cRodape)+'</b></p>'
EndIf

If !EMPTY(cEmail)
	cHtm += '<p style="font-size:8.0pt;font-family: Arial;">Para: '+TRIM(cEmail)+'</p>'
EndIf

If !EMPTY(cEmailCC) 
	cHtm += '<p style="font-size:8.0pt;font-family: Arial;">CC: '+TRIM(cEmailCC)+'</p>'
EndIf

/*
If !EMPTY(cPrw) 
	cHtm += '<p style="font-size:8.0pt;font-family: Arial;">Origem: '+TRIM(cPrw)+' '+DTOC(DATE())+' '+TIME()+' - '+FWEmpName(cEmpAnt)+' - '+cUser+'</p>'
EndIf
*/

cHtm += '<br>'
cHtm += '<a style="font-size:10.0pt;font-family: Arial;text-align:center;" href="javascript:history.back()"><b>Voltar</b></a>'
cHtm += '<br>'

cHtm += '</body>' 
cHtm += '</html>' 
Return cHtm

