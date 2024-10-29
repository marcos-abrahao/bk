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
Local xCampo
Local yCampo

Default cPrw  := ""
Default cRodape := ""
Default cEmail := ""
Default cEmailCC := ""

cHtml += CabHtml(cTitulo)  
//cHtml += Cab1Html(aCabs)

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
		aTamCpo[nJ,2] := ALLTRIM(STR(Round(aTamCpo[nJ,1] * 100/nTotCpo,0),0) + "%")
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
         cHRows += '<th style="padding: 5px; word-break: break-word; font-weight: 700; border-top: 1px solid transparent; border-right: 1px solid transparent; border-bottom: 1px solid transparent; border-left: 1px solid transparent;'+cAlign+' " width="'+aTamCpo[nJ,2]+'"><strong>'+aCabs[nJ]+'</strong></td>'+CRLF
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
         cRows += '<td style="padding: 5px; word-break: break-word; border-top: 1px solid transparent; border-right: 1px solid transparent; border-bottom: 1px solid transparent; border-left: 1px solid transparent;'+cAlign+'" width="'+aTamCpo[nY,2]+'">'+yCampo+'</td>'+CRLF
         //cRows += '<td class="F10A" '+cAlign+'>'+TRIM(yCampo)+'&nbsp;&nbsp;</td>'
	            
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

//cHtml += FimHtml(cPrw,cRodape,cEmail,cEmailCC)

Return cHtml


Static Function CabHtml(cTitulo)
Local cHtml := ""
Local cLogo:= ""

//cLogo := "http://www.bkconsultoria.com.br/image/logobk.jpg"

If FWCodEmp() == "01"      // BK
	cLogo := '<img src="http://www.bkconsultoria.com.br/Imagens/logo_header.png" border=0>'
   //cLogo += '<b><span style="font-size:22.0pt;color:skyblue">BK CONSULTORIA</span></b>'
ElseIf FWCodEmp() == "02"  // MMDK
	cLogo := '<b><span style="font-size:22.0pt;color:skyblue">MMDK</span></b>'
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
ElseIf FWCodEmp() == "12"  // SEGUROS
	cLogo := '<img src="http://www.bkseguros.com.br/wp-content/uploads/2017/04/bk-consultoria-seguros-logo.png" border=0>'
ElseIf FWCodEmp() == "14"  // CONSORCIO BALSA NOVA
	cLogo := '<b><span style="font-size:22.0pt;color:skyblue">CONSÓRCIO BALSA NOVA</span></b>'
ElseIf FWCodEmp() == "15"  // BHG INTERIOR 3
	cLogo := '<b><span style="font-size:22.0pt;color:skyblue">BHG INTERIOR 3</span></b>'
ElseIf FWCodEmp() == "16"  // Consorcio Moove
	cLogo := '<b><span style="font-size:22.0pt;color:skyblue">CONSÓRCIO MOOVE</span></b>'
ElseIf FWCodEmp() == "17"  // DMAF
	cLogo := '<b><span style="font-size:22.0pt;color:skyblue">DMAF</span></b>'
ElseIf FWCodEmp() == "18"  // BK VIA
	cLogo := '<b><span style="font-size:22.0pt;color:skyblue">BK VIA</span></b>'
ElseIf FWCodEmp() == "19"  // BK SOLUÇÕES TECNOLOGICAS
	cLogo := '<b><span style="font-size:22.0pt;color:skyblue">BK SOL. TECNOLOGICAS</span></b>'
Endif	

BEGINCONTENT VAR cHtml
<!DOCTYPE html>

<html lang="pt-BR" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:v="urn:schemas-microsoft-com:vml">
<head>
<title>#TITULO#</title>
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

		a[x-apple-data-detectors] {
			color: inherit !important;
			text-decoration: inherit !important;
		}

		#MessageViewBody a {
			color: inherit;
			text-decoration: none;
		}

		p {
			line-height: inherit
		}

		.desktop_hide,
		.desktop_hide table {
			mso-hide: all;
			display: none;
			max-height: 0px;
			overflow: hidden;
		}

		sup,
		sub {
			font-size: 75%;
			line-height: 0;
		}

		@media (max-width:2000px) {

			.desktop_hide table.icons-inner,
			.social_block.desktop_hide .social-table {
				display: inline-block !important;
			}

			.icons-inner {
				text-align: center;
			}

			.icons-inner td {
				margin: 0 auto;
			}

			.mobile_hide {
				display: none;
			}

			.row-content {
				width: 100% !important;
			}

			.stack .column {
				width: 100%;
				display: block;
			}

			.mobile_hide {
				min-height: 0;
				max-height: 0;
				max-width: 0;
				overflow: hidden;
				font-size: 0px;
			}

			.desktop_hide,
			.desktop_hide table {
				display: table !important;
				max-height: none !important;
			}

			.row-4 .column-1 .block-3.paragraph_block td.pad>div,
			.row-7 .column-1 .block-3.paragraph_block td.pad>div {
				text-align: center !important;
			}

			.row-4 .column-1 .block-3.paragraph_block td.pad,
			.row-7 .column-1 .block-3.paragraph_block td.pad {
				padding: 5px !important;
			}

			.row-5 .column-1 .block-3.paragraph_block td.pad>div {
				font-size: 15px !important;
			}

			.row-7 .column-1 .block-2.paragraph_block td.pad>div {
				text-align: center !important;
				font-size: 32px !important;
			}

			.row-7 .column-1 .block-2.paragraph_block td.pad {
				padding: 5px 5px 0 !important;
			}

		}
	</style>
</head>

<body class="body forceBgColor" style="background-color: transparent; margin: 0; padding: 0; -webkit-text-size-adjust: none; text-size-adjust: none;">

<table align="center" border="0" cellpadding="0" cellspacing="0" class="row row-4" role="presentation" style="mso-table-lspace: 0pt; mso-table-rspace: 0pt; background-size: auto;" width="100%">
	<tbody>
		<tr>
			<td>
				<table align="center" border="0" cellpadding="0" cellspacing="0" class="row-content stack" role="presentation" style="mso-table-lspace: 0pt; mso-table-rspace: 0pt; border-radius: 0; color: #000000; background-size: auto; background-color: #fdf1f1; border-left: 30px solid transparent; border-right: 30px solid transparent; border-top: 30px solid transparent; width: 100%; margin: 0 auto;">
					<tbody>
						<tr>
							<td class="column column-1" style="mso-table-lspace: 0pt; mso-table-rspace: 0pt; font-weight: 400; text-align: left; background-color: #ffffff; padding-bottom: 3px; padding-top: 30px; vertical-align: top; border-top: 0px; border-right: 0px; border-bottom: 0px; border-left: 0px;" width="100%">
								<table border="0" cellpadding="0" cellspacing="0" class="paragraph_block block-2" role="presentation" style="mso-table-lspace: 0pt; mso-table-rspace: 0pt; word-break: break-word;" width="100%">
									<tr>
										<td class="pad">
											<div style="color:#222222;direction:ltr;font-family:'Helvetica Neue', Helvetica, Arial, sans-serif;font-size:40px;font-weight:700;letter-spacing:0px;line-height:120%;text-align:left;mso-line-height-alt:48px;">
												<p style="margin: 0;"><strong>#EMPRESA#</strong></p>
											</div>
										</td>
									</tr>
								</table>
								<table border="0" cellpadding="0" cellspacing="0" class="heading_block block-1" role="presentation" style="mso-table-lspace: 0pt; mso-table-rspace: 0pt;" width="100%">
									<tr>
										<td class="pad" style="text-align:center;width:100%;">
											<h1 style="margin: 0; color: #222222; direction: ltr; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; font-size: 24px; font-weight: 400; letter-spacing: -1px; line-height: 120%; text-align: center; margin-top: 0; margin-bottom: 0; mso-line-height-alt: 28.799999999999997px;"><span class="tinyMce-placeholder" style="word-break: break-word;">#TITULO#</span></h1>
										</td>
									</tr>
								</table>
								<table border="0" cellpadding="0" cellspacing="0" class="paragraph_block block-3" role="presentation" style="mso-table-lspace: 0pt; mso-table-rspace: 0pt; word-break: break-word;" width="100%">
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
<table align="center" border="0" cellpadding="0" cellspacing="0" class="row row-5" role="presentation" style="mso-table-lspace: 0pt; mso-table-rspace: 0pt;" width="100%">
	<tbody>
		<tr>
			<td>
				<table align="center" border="0" cellpadding="0" cellspacing="0" class="row-content stack" role="presentation" style="mso-table-lspace: 0pt; mso-table-rspace: 0pt; background-color: #fdf1f1; border-radius: 0; color: #000000; border-left: 20px solid transparent; border-right: 20px solid transparent; border-top: 0px solid transparent; width: 100%; margin: 0 auto;">
					<tbody>
						<tr>
							<td class="column column-1" style="mso-table-lspace: 0pt; mso-table-rspace: 0pt; font-weight: 400; text-align: left; padding-bottom: 3px; vertical-align: top; border-top: 0px; border-right: 0px; border-bottom: 0px; border-left: 0px;" width="100%">
								<table border="0" cellpadding="10" cellspacing="0" class="table_block mobile_hide block-1" role="presentation" style="mso-table-lspace: 0pt; mso-table-rspace: 0pt;" width="100%">
									<tr>
										<td class="pad">
											<table style="mso-table-lspace: 0pt; mso-table-rspace: 0pt; border-collapse: collapse; width: 100%; table-layout: fixed; direction: ltr; background-color: #ffffff; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; font-weight: 400; color: #222222; text-align: right; letter-spacing: 0px; word-break: break-all;width: 100%;">
												<thead style="vertical-align: top; background-color: #9E0000; color: #FFFFFF; font-size: 16px; line-height: 120%;">
                                       				#CABEC#
												</thead>
												<tbody style="vertical-align: top; font-size: 14px; line-height: 120%;">
                                       				#LINHAS#
												</tbody>
											</table>
										</td>
									</tr>
								</table>

								<table border="0" cellpadding="10" cellspacing="0" class="table_block desktop_hide block-2" role="presentation" style="mso-table-lspace: 0pt; mso-table-rspace: 0pt; mso-hide: all; display: none; max-height: 0; overflow: hidden;" width="100%">
									<tr>
										<td class="pad">
											<table style="mso-table-lspace: 0pt; mso-table-rspace: 0pt; mso-hide: all; display: none; max-height: 0; overflow: hidden; border-collapse: collapse; width: 100%; table-layout: fixed; direction: ltr; background-color: #ffffff; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; font-weight: 400; color: #222222; text-align: right; letter-spacing: 0px; word-break: break-all;" width="100%">
												<thead style="vertical-align: top; background-color: #9E0000; color: #FFFFFF; font-size: 11px; line-height: 120%;">
                                       				#CABEC#
												</thead>
												<tbody style="vertical-align: top; font-size: 11px; line-height: 120%;">
                                       				#LINHAS#
												</tbody>
											</table>
										</td>
									</tr>
								</table>

								<table border="0" cellpadding="25" cellspacing="0" class="button_block block-3" role="presentation" style="mso-table-lspace: 0pt; mso-table-rspace: 0pt;" width="100%">
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

<table align="center" border="0" cellpadding="0" cellspacing="0" class="row row-7" role="presentation" style="mso-table-lspace: 0pt; mso-table-rspace: 0pt;" width="100%">
	<tbody>
		<tr>
			<td>
				<table align="center" border="0" cellpadding="0" cellspacing="0" class="row-content stack" role="presentation" style="mso-table-lspace: 0pt; mso-table-rspace: 0pt; background-repeat: no-repeat; background-color: #fdf1f1; border-radius: 0; color: #000000; background-size: cover; width: 100%; margin: 0 auto;">
					<tbody>
						<tr>
							<td class="column column-1" style="mso-table-lspace: 0pt; mso-table-rspace: 0pt; font-weight: 400; text-align: left; padding-bottom: 4px; padding-left: 15px; padding-right: 15px; padding-top: 0px; vertical-align: top; border-top: 0px; border-right: 0px; border-bottom: 0px; border-left: 0px; width: 100%;">
								<table border="0" cellpadding="0" cellspacing="0" class="paragraph_block block-3" role="presentation" style="mso-table-lspace: 0pt; mso-table-rspace: 0pt; word-break: break-word;" width="100%">
									<tr>
										<td class="pad" style="padding-bottom:5px;padding-left:25px;padding-right:25px;padding-top:5px;">
											<div style="color:#222222;font-family:'Helvetica Neue', Helvetica, Arial, sans-serif;font-size:15px;font-weight:400;line-height:150%;text-align:left;mso-line-height-alt:22.5px;">
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

cHtml := STRTRAN(cHtml,"#TITULO#" ,cTitulo)
cHtml := STRTRAN(cHtml,"#EMPRESA#",cLogo)

/*


												<a href="javascript:history.back()" style="background-color:#222222;border-bottom:0px solid transparent;border-left:0px solid transparent;border-radius:10px;border-right:0px solid transparent;border-top:0px solid transparent;color:#ffffff;display:inline-block;font-family:'Helvetica Neue', Helvetica, Arial, sans-serif;font-size:14px;font-weight:400;mso-border-alt:none;padding-bottom:5px;padding-top:5px;text-align:center;text-decoration:none;width:auto;word-break:keep-all;" target="_blank">
													<span style="word-break: break-word; padding-left: 30px; padding-right: 30px; font-size: 14px; display: inline-block; letter-spacing: 2px;">
														<span style="margin: 0; word-break: break-word; line-height: 28px;">Voltar</span>
													</span>
												</a>

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
cHtm += ' <tr>' 
cHtm += '  <td width=15% class="Normal">' 
cHtm += '    <p align=center style="text-align:center">'+cLogo+'</p>' 
cHtm += '  </td>' 
cHtm += '  <td class="Normal" width=85% style="center" >' 
cHtm += '    <p align=center style="text-align:center;font-size:18.0"><b>'+cTitulo+'</b></p>' 
cHtm += '    </td>' 
cHtm += ' </tr>' 
cHtm += '</table>' 
cHtm += '<br>' 
*/

Return cHtml


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



Static Function FimHtml(cPrw,cRodape,cEmail,cEmailCC)
Local cHtm        := ""
Local cUser       := ""
Default cPrw      := ""
Default cEmail    := ""
Default cEmailCC  := ""

If ValType(cUserName) == "U"
   cUser := "Admin"
Else
   cUser := cUserName
EndIf

cHtm += '</table>' 

If !EMPTY(cRodape) 
   cHtm += '<br>'
	cHtm += TRIM(cRodape)
EndIf

If !EMPTY(cEmail)
   cHtm += '<br>'
	cHtm += '<p class="F8A">Para: '+TRIM(cEmail)
EndIf

If !EMPTY(cEmailCC) 
   cHtm += '<br>'
	cHtm += '<p class="F8A">CC: '+TRIM(cEmailCC)
EndIf

If !EMPTY(cPrw) 
   cHtm += '<br>'
	cHtm += '<p class="F8A">Origem: '+TRIM(cPrw)+' '+DTOC(DATE())+' '+TIME()+' - '+FWEmpName(cEmpAnt)+' - '+cUser+'</p>'
   cHtm += '<a class="F10A" href="javascript:history.back()">Voltar</a>'
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

