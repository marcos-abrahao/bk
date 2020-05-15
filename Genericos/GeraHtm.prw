#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

// Funcão para gerar texto Html

User Function GeraHtmA(aDet,cTitulo,aCabs,cPrw)
Local cMsg := ""
Local _ni,_nJ
Local lCorNao := .T.
Local cPicN   := "@E 99999999.99"
Local cAlign  := ""
Default cPrw  := ""

cMsg += CabHtml(cTitulo)   
cMsg += Cab1Html(aCabs)

For _nJ := 1 TO LEN(aDet)

    If lCorNao   
       cMsg += '<tr>'
    Else   
       cMsg += '<tr bgcolor="#dfdfdf">'
    EndIf   
    lCorNao := !lCorNao
	
    For _ni :=1 to LEN(aDet[_nj])
	
         xCampo := aDet[_nJ,_ni]
	            
         _uValor := ""
         cAlign  :=	"nowrap"
			            
         if VALTYPE(xCampo) == "D" // Trata campos data
            _uValor := dtoc(xCampo)
         elseif VALTYPE(xCampo) == "N" // Trata campos numericos
            _uValor := ALLTRIM(transform(xCampo,cPicN))
            cAlign := 'align="right"'
         elseif VALTYPE(xCampo) == "C" // Trata campos caracter
            _uValor := ALLTRIM(xCampo)
         endif
            
         cMsg += '<td class="F10A" '+cAlign+'>'+TRIM(_uValor)+'&nbsp;&nbsp;</td>'
	            
      Next _ni

      cMsg += '</tr>'
	
Next _nJ

cMsg += FimHtml(cPrw)

Return cMsg


Static Function CabHtml(cTitulo)
Local cHtm := ""
Local cLogo:= ""

//cLogo := "http://www.bkconsultoria.com.br/image/logobk.jpg"

If FWCodEmp() == "01"      // BK
	cLogo := '<img src="http://www.bkconsultoria.com.br/Imagens/logo_header.png" border=0>'
ElseIf FWCodEmp() == "02"  // HF
	cLogo := '<b><span style="font-size:22.0pt;color:skyblue">BK TERCEIRIZADOS</span></b>'
ElseIf FWCodEmp() == "04"  // ESA
	cLogo := '<b><span style="font-size:22.0pt;color:skyblue">ESA</span></b>'
ElseIf FWCodEmp() == "06"  // BKDAHER SUZANO
	cLogo := '<b><span style="font-size:22.0pt;color:skyblue">BKDAHER SUZANO</span></b>'
ElseIf FWCodEmp() == "07"  // JUSTFOFTWARE
	cLogo := '<b><span style="font-size:22.0pt;color:skyblue">JUST</span></b>'
ElseIf FWCodEmp() == "08"  // BHG CAMPINAS
	cLogo := '<b><span style="font-size:22.0pt;color:skyblue">BHG CAMPINAS</span></b>'
ElseIf FWCodEmp() == "09"  // BHG OSASCO
	cLogo := '<b><span style="font-size:22.0pt;color:skyblue">BHG OSASCO</span></b>'
ElseIf FWCodEmp() == "10"  // BKDAHER TABOAO DA SERRA
	cLogo := '<b><span style="font-size:22.0pt;color:skyblue">BKDAHER TABOAO DA SERRA</span></b>'
ElseIf FWCodEmp() == "11"  // BKDAHER LIMEIRA
	cLogo := '<b><span style="font-size:22.0pt;color:skyblue">BKDAHER LIMEIRA</span></b>'
ElseIf FWCodEmp() == "12"  // BKDAHER SEGUROS
	cLogo := '<img src="http://www.bkseguros.com.br/wp-content/uploads/2017/04/bk-consultoria-seguros-logo.png" border=0>'
ElseIf FWCodEmp() == "14"  // CONSORCIO BALSA NOVA
	cLogo := '<b><span style="font-size:22.0pt;color:skyblue">CONSORCIO BALSA NOVA</span></b>'
Endif	

cHtm += '<html>' 
cHtm += '<head>' 
cHtm += '<meta http-equiv=Content-Type content="text/html; charset=iso-8859-1">' 
cHtm += '<link rel=Edit-Time-Data href="./HistD_arquivos/editdata.mso">' 
cHtm += '<title>'+cTitulo+' - '+DTOC(date())+' '+TIME()+'</title>' 
cHtm += '<style>' 
cHtm += '.Normal{font-size:11.0pt;font-family:"Arial";}' 
cHtm += '.F6A{font-size:6.0;font-family:"Arial"}' 
cHtm += '.F8A{font-size:8.0;font-family:"Arial"}' 
cHtm += '.F10A{font-size:10.0;font-family:"Arial"}' 
cHtm += '.F11A{font-size:11.0;font-family:"Arial"}' 
cHtm += '.F11AC{font-size:11.0;font-family:"Arial";text-align:"center"}' 
cHtm += '.F14A{font-size:14.0;font-family:"Arial"}' 
cHtm += '</style>' 
cHtm += '</head>' 
cHtm += '<body bgcolor=#ffffff lang=PT-BR class="Normal">' 

cHtm += '<table border=0 align="center" cellpadding=0 width="100%" style="center" >' 
cHtm += '  <tr>' 
cHtm += '  <td width=15% class="Normal">' 
cHtm += '    <p align=center style="text-align:center">'+cLogo+'</p>' 
cHtm += '  </td>' 
cHtm += '  <td class="Normal" width=85% style="center" >' 
cHtm += '    <p align=center style="text-align:center;font-size:18.0"><b>'+cTitulo+'</b></p>' 
cHtm += '    </td>' 
cHtm += '  </tr>' 
cHtm += '</table>' 
cHtm += '<br>' 
Return cHtm



Static Function Cab1Html(aCabs)
Local cHtm := ""
Local nI 


cHtm += '<table width="100%" Align="center" border="0" cellspacing="0" cellpadding="0" bordercolor="#CCCCCC" >' 
cHtm += '  <tr bgcolor="#dfdfdf">' 

For nI := 1 TO LEN(aCabs)
	cHtm += '    <td class="F10A" nowrap><b>'+ALLTRIM(aCabs[nI])+'</b></td>' 

//cHtm += '    <td width="10%" class="F11A"><b>Contrato</b></td>' 
//cHtm += '    <td width="5%" class="F11A"><b>Revisão</b></td>' 
//cHtm += '    <td width="30%" class="F11A"><b>Descrição</b></td>' 
//cHtm += '    <td width="20%" class="F11A"><b>Aviso</b></td>' 
//cHtm += '    <td width="10%" class="F11A"><b>Repactuação</b></td>' 
//cHtm += '    <td width="15%" class="F11A"><b>Observaçoes</b></td>' 
//cHtm += '    <td width="10%" class="F11A"><b>Status</b></td>' 

Next

cHtm += '  </tr>' 
Return cHtm



Static Function FimHtml(cPrw)
Local cHtm := ""
Default cPrw := ""

cHtm += '</table>' 
cHtm += '<br>'
If !EMPTY(cPrw) 
	cHtm += '<p class="F8A">Origem: '+TRIM(cPrw)+' '+DTOC(DATE())+' '+TIME()+' - '+TRIM(SM0->M0_NOME)+'</p> 
EndIf

/*
cHtm += '<table border=1 cellspacing=0 cellpadding=0 width="100%" align="center" bordercolor="#CCCCCC">' 
cHtm += ' <tr>' 
cHtm += '  <td width="70%" class="Normal"><p><font size="2"><b>' 
cHtm += 'Observações:' 
cHtm += '  </b></font></p></td>' 
cHtm += ' </tr>' 
cHtm += ' <tr>' 
cHtm += '  <td width="100%" class="F11A">' 
cHtm += '  <p>' 
//cHtm += TRIM(cObsTab)+'<br>' 
cHtm += '<br>' 
cHtm += '  </p>' 
cHtm += '  </td>' 
cHtm += '  </tr>' 
cHtm += ' <tr>' 
cHtm += ' </tr>' 
cHtm += '</table>' 
*/

cHtm += '</body>' 
cHtm += '</html>' 
Return cHtm

