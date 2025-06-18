#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

// Funcão para gerar texto Html

User Function GeraHtmA(aDet,cTitulo,aCabs,cPrw,cRodape,cEmail,cEmailCC)
Local cHtml    := ""
Local cRows    := ""
Local cHRows   := ""
Local nY	   := 0
Local nJ       := 0
Local lCorNao  := .T.
Local cPicN    := "@E 99999999.99"
Local cAlign   := ""
Local aTamCpo  := {}
Local nTamCpo  := 0
Local nTotCpo  := 0
Local nPerCpo  := 0
Local xCampo
Local yCampo

Default cPrw  := ""
Default cRodape := ""
Default cEmail := ""
Default cEmailCC := ""

cHtml += CabHtml(cTitulo)  

// Calculo do % do tamanho dos campo
If Len(aDet) > 0
   For nJ := 1 TO LEN(aDet[1])
   	  xCampo := aDet[1,nJ]
      nTamCpo := Len(cValToChar(xCampo))
      If VALTYPE(xCampo) == "D" .AND. nTamCpo < 10// Trata campos data
         nTamCpo := 10
      ElseIf VALTYPE(xCampo) == "N" .AND. nTamCpo < 12// Trata campos numericos
         nTamCpo := 14
      ElseIf VALTYPE(xCampo) == "C" // Trata campos caracter
         nTamCpo := LEN(xCampo)
		 If nTamCpo < 10
		 	nTamCpo := 10
		EndIf
      Endif
      aAdd(aTamCpo,{nTamCpo,""})
      nTotCpo += nTamCpo   
   Next

   For nJ := 1 TO LEN(aTamCpo)
   		nPerCpo := aTamCpo[nJ,1] * 100/nTotCpo
		If nPerCpo < 10
			nPerCpo := 10
		EndIf
		aTamCpo[nJ,2] := ALLTRIM(STR(Round(nPerCpo,0),0) + "%")
   Next

   cHRows += '<tr>'+CRLF
   For nJ := 1 To LEN(aDet[1])

         xCampo := aDet[1,nJ]
         cAlign := "text-align: left;"
			            
         if VALTYPE(xCampo) == "D" // Trata campos data
            cAlign := 'text-align: center;'
         elseif VALTYPE(xCampo) == "N" // Trata campos numericos
            cAlign := 'text-align: right;'
         endif
         //cHRows += '<th style="padding: 2px; word-break: break-word; font-weight: 700; border-top: 1px solid transparent; border-right: 1px solid transparent; border-bottom: 1px solid transparent; border-left: 1px solid transparent;'+cAlign+' " width="'+aTamCpo[nJ,2]+'"><strong>'+aCabs[nJ]+'</strong></td>'+CRLF
         //cHRows += '<th style="padding: 5px; word-break: break-word; font-weight: 700; border-top: 1px solid transparent; border-right: 1px solid transparent; border-bottom: 1px solid transparent; border-left: 1px solid transparent;'+cAlign+' " min-width="20px"><strong>'+aCabs[nJ]+'</strong></td>'+CRLF
		 cHRows += '<td style="padding: 5px 2px 5px 2px;'+cAlign+'"><strong>'+aCabs[nJ]+'</strong></td>'+CRLF
   Next
   cHRows += '</tr>'+CRLF
EndIf

For nJ := 1 TO LEN(aDet)

    If lCorNao   
       cRows += '<tr>'+CRLF
    Else   
       cRows += '<tr style="background-color:#fdf1f1;">'+CRLF
    EndIf   
    lCorNao := !lCorNao
	
    For nY :=1 to LEN(aDet[nj])
	
         xCampo := aDet[nJ,nY]
	            
         yCampo := xCampo
         cAlign := 'text-align: left;'
			            
         if VALTYPE(xCampo) == "D" // Trata campos data
            yCampo := DTOC(xCampo)
            cAlign := 'text-align: center;'
         elseif VALTYPE(xCampo) == "N" // Trata campos numericos
            yCampo := ALLTRIM(TRANSFORM(xCampo,cPicN))
            cAlign := 'text-align: right;'
         endif
         //cRows += '<td style="padding: 5px; word-break: break-word; border-top: 1px solid transparent; border-right: 1px solid transparent; border-bottom: 1px solid transparent; border-left: 1px solid transparent;'+cAlign+'" width="'+aTamCpo[nY,2]+'">'+yCampo+'</td>'+CRLF
         //cRows += '<td style="padding: 5px; word-break: break-word; border-top: 1px solid transparent; border-right: 1px solid transparent; border-bottom: 1px solid transparent; border-left: 1px solid transparent;'+cAlign+'" min-width="20px">'+yCampo+'</td>'+CRLF
         cRows += '<td style="padding: 5px 2px 5px 2px; white-space: nowrap;'+cAlign+'">'+yCampo+'</td>'+CRLF
	            
      Next nY

      cRows += '</tr>'+CRLF
	
Next nJ

cHtml := STRTRAN(cHtml,"#CABEC#",cHRows)
cHtml := STRTRAN(cHtml,"#LINHAS#",cRows)

cHtml := STRTRAN(cHtml,"#FONTE#",cPrw+' - '+DTOC(date())+' '+TIME())
If !Empty(cRodape)
	cHtml := STRTRAN(cHtml,"#RODAPE#",cRodape)
Else
	cHtml := STRTRAN(cHtml,"#RODAPE#"," ")
EndIf
If !Empty(cEmail)
	cHtml := STRTRAN(cHtml,"#EMAIL#","Enviado para: "+cEmail)
Else
	cHtml := STRTRAN(cHtml,"#EMAIL#"," ")
EndIf
If !Empty(cEmailCC)
	cHtml := STRTRAN(cHtml,"#EMAILCC#","Com Copia: "+cEmailCC)
Else
	cHtml := STRTRAN(cHtml,"#EMAILCC#"," ")
EndIf

Return cHtml


Static Function CabHtml(cTitulo)
Local cHtml := ""
Local cLogo:= ""

cLogo := u_BkLogos()

BEGINCONTENT VAR cHtml
<!DOCTYPE html>

<html lang="pt-BR" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:v="urn:schemas-microsoft-com:vml">
<head>
<title>#TITULO#</title>
#BKFavIco#
<meta content="text/html; charset=utf-8" http-equiv="Content-Type"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/><!--[if mso]><xml><o:OfficeDocumentSettings><o:PixelsPerInch>96</o:PixelsPerInch><o:AllowPNG/></o:OfficeDocumentSettings></xml><![endif]-->
<style>
	* {
		box-sizing: border-box;
	}
	body {
		margin: 0;
		padding: 0;
	}

	p {
		line-height: inherit
	}

</style>
</head>

<body class="body forceBgColor" style="background-color: transparent; margin: 0; padding: 0; -webkit-text-size-adjust: none; text-size-adjust: none;">

<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-size: auto;" width="100%">
	<tbody>
		<tr>
			<td>
				<table align="center" border="0" cellpadding="0" cellspacing="0" class="row-content stack" style="border-radius: 0; color: #000000; background-size: auto; background-color: #fdf1f1; border-left: 30px solid transparent; border-right: 30px solid transparent; border-top: 30px solid transparent; width: 100%; margin: 0 auto;">
					<tbody>
						<tr>
							<td style="font-weight: 400; text-align: left; background-color: #ffffff; padding-bottom: 3px; padding-top: 30px; vertical-align: top; border-top: 0px; border-right: 0px; border-bottom: 0px; border-left: 0px;" width="100%">
								<table border="0" cellpadding="0" cellspacing="0" class="paragraph_block block-2" style="word-break: break-word;" width="100%">
									<tr>
										<td class="pad">
											<div style="color:#222222;direction:ltr;font-family:'Helvetica Neue', Helvetica, Arial, sans-serif;font-size:40px;font-weight:700;letter-spacing:0px;line-height:120%;text-align:left;mso-line-height-alt:48px;">
												<p style="margin: 0;"><strong>#EMPRESA#</strong></p>
											</div>
										</td>
									</tr>
								</table>
								<table border="0" cellpadding="0" cellspacing="0" class="heading_block block-1" width="100%">
									<tr>
										<td class="pad" style="text-align:center;width:100%;">
											<h1 style="margin: 0; color: #222222; direction: ltr; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; font-size: 24px; font-weight: 400; letter-spacing: -1px; line-height: 120%; text-align: center; margin-top: 0; margin-bottom: 0; mso-line-height-alt: 28.799999999999997px;"><span class="tinyMce-placeholder" style="word-break: break-word;">#TITULO#</span></h1>
										</td>
									</tr>
								</table>
								<table border="0" cellpadding="0" cellspacing="0" class="paragraph_block block-3" style="word-break: break-word;" width="100%">
									<tr>
										<td class="pad" style="padding-top:5px;">
											<div style="color:#222222;font-family:'Helvetica Neue', Helvetica, Arial, sans-serif;font-size:14px;font-weight:400;line-height:150%;text-align:center;mso-line-height-alt:21px;">
												<p style="margin: 0; word-break: break-word;">Origem: #FONTE#</p>
											</div>
										</td>
									</tr>
								</table>
							</td>
						</tr>
					</tbody>
				</table>
			</td>
		</tr>
	</tbody>
</table>
<table align="center" border="0" cellpadding="0" cellspacing="0" width="100%">
	<tbody>
		<tr>
			<td>
				<table align="center" border="0" cellpadding="0" cellspacing="0" class="row-content stack" style="background-color: #fdf1f1; border-radius: 0; color: #000000; border-left: 20px solid transparent; border-right: 20px solid transparent; border-top: 0px solid transparent; width: 100%; margin: 0 auto;">
					<tbody>
						<tr>
							<td style="font-weight: 400; text-align: left; padding-bottom: 3px; vertical-align: top; border-top: 0px; border-right: 0px; border-bottom: 0px; border-left: 0px;" width="100%">

								<table border="0" cellpadding="10" cellspacing="0" style="" width="100%">
									<tr>
										<td class="pad">
											<table style="border-collapse: collapse; width: 100%; table-layout: auto; direction: ltr; background-color: #ffffff; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; font-weight: 400; color: #222222; text-align: right; letter-spacing: 0px; word-break: break-all;" width="100%">
												<thead style="vertical-align: top; background-color: #9E0000; color: #FFFFFF; font-size: 10px; line-height: 120%;">
                                       				#CABEC#
												</thead>
												<tbody style="vertical-align: top; font-size: 9px; line-height: 120%;">
                                       				#LINHAS#
												</tbody>
											</table>
										</td>
									</tr>
								</table>

								<table border="0" cellpadding="25" cellspacing="0" class="button_block block-3" width="100%">
									<tr>
										<td class="pad">
											<div align="center" class="alignment">
												<a href="javascript:history.back()">Voltar</a>
											</div>
										</td>
									</tr>
								</table>

							</td>
						</tr>
					</tbody>
				</table>
			</td>
		</tr>
	</tbody>
</table>

<table align="center" border="0" cellpadding="0" cellspacing="0" class="row row-7" width="100%">
	<tbody>
		<tr>
			<td>
				<table align="center" border="0" cellpadding="0" cellspacing="0" class="row-content stack" style="background-repeat: no-repeat; background-color: #fdf1f1; border-radius: 0; color: #000000; background-size: cover; width: 100%; margin: 0 auto;">
					<tbody>
						<tr>
							<td style="font-weight: 400; text-align: left; padding-bottom: 4px; padding-left: 15px; padding-right: 15px; padding-top: 0px; vertical-align: top; border-top: 0px; border-right: 0px; border-bottom: 0px; border-left: 0px; width: 100%;">
								<table border="0" cellpadding="0" cellspacing="0" class="paragraph_block block-3" style="word-break: break-word;" width="100%">
									<tr>
										<td class="pad" style="padding-bottom:5px;padding-left:25px;padding-right:25px;padding-top:5px;">
											<div style="color:#222222;font-family:'Helvetica Neue', Helvetica, Arial, sans-serif;font-size:9px;font-weight:400;line-height:150%;text-align:left;mso-line-height-alt:22.5px;">
												<p style="margin: 0; word-break: break-word;">#RODAPE#</p>
												<p style="margin: 0; word-break: break-word;">#EMAIL#</p>
												<p style="margin: 0; word-break: break-word;">#EMAILCC#</p>
											</div>
										</td>
									</tr>
								</table>
							</td>
						</tr>
					</tbody>
				</table>
			</td>
		</tr>
	</tbody>
</table>

</body>
</html>
ENDCONTENT

cHtml := STRTRAN(cHtml,"#TITULO#"  ,cTitulo)
cHtml := STRTRAN(cHtml,"#BKFavIco#",u_BkFavIco())
cHtml := STRTRAN(cHtml,"#EMPRESA#" ,cLogo)

Return cHtml
