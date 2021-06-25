#include "protheus.ch"
#include "fileio.ch"
 
static oCellHorAlign := FwXlsxCellAlignment():Horizontal()
static oCellVertAlign := FwXlsxCellAlignment():Vertical()
 
function u_fwprtxlsx()
    classe()
    alert('terminou')
return
 
 
static function classe()
    // Antes de rodar este programa coloque uma imagem válida nos diretórios mencionados a seguir
    // ou indique um caminho válido para uma imagem
    //local cRootPath := 'C:\Especif\Protheus12\sistemico\protheus_data_27'
    local cRootPath := 'C:\tmp'
    local cPath := "\spool\"  // /spool/ para uma geração no server
    local cArquivo := cPath + "exemplo.rel"
    local cImgRel := 'logo'
    local cImgDir := cRootPath + cPath + 'LGMID01.png'
 
    local cBuffer:= ""
 
    local lRet := .F.
    local oFileW := FwFileWriter():New(cArquivo)
    local oPrtXlsx := FwPrinterXlsx():New()
 
    local nHndImagem := 0
    local nLenImagem := 0
    local jFontHeader
    local jFontNum
    local jFontText
    local jBorderHeader
    local jBorderLeft
    local jBorderCenter
    local jBorderRight
    local jFormat
 
    lRet := oPrtXlsx:Activate(cArquivo, oFileW)
 
    lRet := oPrtXlsx:AddSheet("Minha Plan1")
 
    // Atenção, antes de remover os comentários dos comandos a seguir
    // confira o endereço para a imagem
    // nHndImagem := fOpen(cImgDir, FO_READ)
    // if nHndImagem < 0
    //     return MsgStop("Não foi possível abrir " + cImgDir)
    // endif
 
    // nLenImagem := fSeek( nHndImagem, 0, FS_END)
    // fSeek( nHndImagem, 0, FS_SET)
    // fRead( nHndImagem, @cBuffer, nLenImagem)
 
    // lRet := oPrtXlsx:AddImageFromBuffer(5, 8, cImgRel, cBuffer, 0, 0)
    // lRet := oPrtXlsx:AddImageFromAbsolutePath(10, 8, cImgDir, 200, 100)
    // lRet := oPrtXlsx:UseImageFromBuffer(20, 8, cImgRel, 114, 33)
 
    // cFont := FwPrinterFont():getFromName("Calibri")
    cFont := FwPrinterFont():Calibri()
    nSize := 14
    lItalic := .T.
    lBold := .T.
    lUnderlined := .T.
    // Comando 'Fonte' com Calibri 14, itálico, negrito e sublinhado
    lRet := oPrtXlsx:SetFont(cFont, nSize, lItalic, lBold, lUnderlined)
 
    cHorAlignment := oCellHorAlign:Default()
    cVertAlignment := oCellVertAlign:Default()
    lWrapText := .F.
    nRotation := 0
    // Comando 'Formato de Célula' com cor de texto e fundo personalizadas
    lRet := oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, lWrapText, nRotation, "FF0000", "C0C0C0", "" )
 
    nColFrom := 1
    nColTo := 5
    nWidth := 24
    lRet := oPrtXlsx:SetColumnsWidth(nColFrom, nColTo, nWidth)
 
    nRow := 1
    nCol := 1
    // Texto em A1
    lRet := oPrtXlsx:SetText(nRow, nCol, "Texto na célula")
    lRet := oPrtXlsx:SetText(nRow, nCol+1, "Texto2 na célula")
 
    // cFont := FwPrinterFont():getFromName("Calibri")
    cFont := FwPrinterFont():Calibri()
    nSize := 11
    lItalic := .F.
    lBold := .F.
    lUnderlined := .F.
    // Calibri 11
    lRet := oPrtXlsx:SetFont(cFont, nSize, lItalic, lBold, lUnderlined)
 
    lRet := oPrtXlsx:ResetCellsFormat()
 
    nRow := 2
    nCol := 1
    lRet := oPrtXlsx:SetText(nRow, nCol, "00123")
 
    nRow := 3
    nCol := 1
    // Número 008
    lRet := oPrtXlsx:SetNumber(nRow, nCol, 8)
 
    nRow := 4
    nCol := 1
    // Número 04
    lRet := oPrtXlsx:SetNumber(nRow, nCol, 4)
 
    nRow := 5
    nCol := 1
    // Fórmula que soma os dois números anteriores
    lRet := oPrtXlsx:SetFormula(nRow, nCol, "=SUM(A3:A4)")
 
    cHorAlignment := oCellHorAlign:Default()
    cVertAlignment := oCellVertAlign:Default()
    lWrapText := .F.
    nRotation := 0
    cCustomFormat := "#,##0"
    // Comando 'Formato de Célula' com cor de texto e fundo personalizadas
    lRet := oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, lWrapText, nRotation, "000000", "FFFFFF", cCustomFormat)
 
    nRow := 4
    nCol := 2
    // Número com formato customizado (123.123.123)
    lRet := oPrtXlsx:SetNumber(nRow, nCol, 123123123)
 
    cHorAlignment := oCellHorAlign:Default()
    cVertAlignment := oCellVertAlign:Default()
    lWrapText := .F.
    nRotation := 0
    cCustomFormat := "0.00%"
    // Comando 'Formato de Célula' com cor de texto e fundo personalizadas
    lRet := oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, lWrapText, nRotation, "000000", "FFFFFF", cCustomFormat)
 
    nRow := 4
    nCol := 3
    // Número com formato customizado (4,27%)
    lRet := oPrtXlsx:SetNumber(nRow, nCol, 0.0427)
 
    cHorAlignment := oCellHorAlign:Default()
    cVertAlignment := oCellVertAlign:Default()
    lWrapText := .F.
    nRotation := 0
    cCustomFormat := "R$ #,##0.00;[Red]-R$ #,##0.00"
    // Seta formato numérico R$ #,##0.00;[Red]-R$ #,##0.00
    lRet := oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, lWrapText, nRotation, "000000", "FFFFFF", cCustomFormat)
 
    nRow := 4
    nCol := 4
    // Número com formato customizado (R$ 1234,56)
    lRet := oPrtXlsx:SetNumber(nRow, nCol, 1234.56)
 
    nRow := 4
    nCol := 5
    // Número com formato customizado (R$ 1234,56)
    lRet := oPrtXlsx:SetNumber(nRow, nCol, -1234.56)
 
    cHorAlignment := oCellHorAlign:Default()
    cVertAlignment := oCellVertAlign:Default()
    lWrapText := .F.
    nRotation := 0
    cCustomFormat := "dd/mm/yyyy"
    // Seta formato de data dd/mm/yyyy
    lRet := oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, lWrapText, nRotation, "000000", "FFFFFF", cCustomFormat)
 
    nRow := 6
    nCol := 1
    dValue := STOD("20190823")
    // Data "ano, mês, dia, hora, minuto, segundo" no padrão: yyyy,mm,dd,hh,mm,ss.sss
    lRet := oPrtXlsx:SetDate(nRow, nCol, dValue)
 
    cHorAlignment := oCellHorAlign:Default()
    cVertAlignment := oCellVertAlign:Default()
    lWrapText := .F.
    nRotation := 0
    cCustomFormat := "hh:mm"
    // Seta formato de hora hh:mm
    lRet := oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, lWrapText, nRotation, "000000", "FFFFFF", cCustomFormat)
 
    nRow := 6
    nCol := 2
    oPrtXlsxDate := FwXlsxDateFormat():New()
    oPrtXlsxDate:SetHour("17")
    oPrtXlsxDate:SetMinute("55")
    cValue := oPrtXlsxDate:toPrinterFormat()
    // 17:55
    lRet := oPrtXlsx:SetDateTime(nRow, nCol, cValue)
 
    cHorAlignment := oCellHorAlign:Default()
    cVertAlignment := oCellVertAlign:Default()
    lWrapText := .F.
    nRotation := 0
    cCustomFormat := "dd/mm/yy hh:mm:ss.000"
    // Seta formato de data e hora dd/mm/yy hh:mm:ss.000
    lRet := oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, lWrapText, nRotation, "000000", "FFFFFF", cCustomFormat)
 
    nRow := 6
    nCol := 3
    oPrtXlsxDate := FwXlsxDateFormat():New()
    oPrtXlsxDate:SetYear("2019")
    oPrtXlsxDate:SetMonth("8")
    oPrtXlsxDate:SetDay("23")
    oPrtXlsxDate:SetHour("17")
    oPrtXlsxDate:SetMinute("55")
    oPrtXlsxDate:SetSeconds("43.123")
    cValue := oPrtXlsxDate:toPrinterFormat()
    // data e hora completas
    lRet := oPrtXlsx:SetDateTime(nRow, nCol, cValue)
 
    nRow := 6
    nCol := 4
    oPrtXlsxDate := FwXlsxDateFormat():New()
    oPrtXlsxDate:SetYear("2019")
    oPrtXlsxDate:SetMonth("8")
    oPrtXlsxDate:SetDay("23")
    oPrtXlsxDate:SetHour("17")
    oPrtXlsxDate:SetMinute("55")
    oPrtXlsxDate:SetSeconds("43.123")
    cValue := oPrtXlsxDate:toPrinterFormat()
    // data e hora completas
    lRet := oPrtXlsx:SetDateTime(nRow, nCol, cValue)
 
    cHorAlignment := oCellHorAlign:Default()
    cVertAlignment := oCellVertAlign:Default()
    lWrapText := .F.
    nRotation := 0
    cCustomFormat := "mmm-yyyy"
    // Seta formato de data mmm-yyyy
    lRet := oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, lWrapText, nRotation, "000000", "FFFFFF", cCustomFormat)
 
    nRow := 6
    nCol := 5
    dValue := STOD("20190823")
    // Data "ano, mês, dia, hora, minuto, segundo" no padrão: yyyy,mm,dd,hh,mm,ss.sss
    lRet := oPrtXlsx:SetDate(nRow, nCol, dValue)
 
    // cFont := FwPrinterFont():getFromName("Calibri")
    cFont := FwPrinterFont():Calibri()
    nSize := 11
    lItalic := .F.
    lBold := .F.
    lUnderlined := .T.
    // Calibri sublinhada para url
    lRet := oPrtXlsx:SetFont(cFont, nSize, lItalic, lBold, lUnderlined)
 
    cHorAlignment := oCellHorAlign:Default()
    cVertAlignment := oCellVertAlign:Default()
    lWrapText := .F.
    nRotation := 0
    cCustomFormat := ""
    // Seta formato com texto azul
    lRet := oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, lWrapText, nRotation, "0000FF", "FFFFFF", cCustomFormat)
 
    nRow := 7
    nCol := 1
    // url
    lRet := oPrtXlsx:SetHyperlink(nRow, nCol, "http://www.totvs.com.br")
 
    nRow := 8
    nCol := 1
    // url
    lRet := oPrtXlsx:SetHyperlink(nRow, nCol, "http://www.google.com")
    // Texto de exibição da url inserida no comando anterior
    lRet := oPrtXlsx:SetText(nRow, nCol, "Google")
 
    nRow := 9
    nCol := 1
    // URIs locais são suportadas para referências
    lRet := oPrtXlsx:SetHyperlink(nRow, nCol, "internal:'Minha Plan1'!A2")
 
    nRow := 10
    nCol := 1
    // URIs locais são suportadas para referências
    lRet := oPrtXlsx:SetHyperlink(nRow, nCol, "internal:'Minha Plan2'!B2")
 
    // cFont := FwPrinterFont():getFromName("Calibri")
    cFont := FwPrinterFont():Calibri()
    nSize := 11
    lItalic := .F.
    lBold := .F.
    lUnderlined := .F.
    // Calibri 11
    lRet := oPrtXlsx:SetFont(cFont, nSize, lItalic, lBold, lUnderlined)
 
    nRow := 11
    nCol := 1
    // lógico
    lRet := oPrtXlsx:SetBoolean(nRow, nCol, .T.)
 
    nRow := 11
    nCol := 2
    // lógico
    lRet := oPrtXlsx:SetBoolean(nRow, nCol, .F.)
 
    cHorAlignment := oCellHorAlign:Fill()
    cVertAlignment := oCellVertAlign:Justify()
    lWrapText := .T.
    nRotation := 0
    cCustomFormat := ""
    // Formato
    lRet := oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, lWrapText, nRotation, "FF00FF", "808080", cCustomFormat)
 
    lTop := .T.
    lBottom := .T.
    lLeft:= .T.
    lRight := .T.
    cStyle := FwXlsxBorderStyle():DashDot()
    cColor := "008000"
    // Borda
    lRet := oPrtXlsx:SetBorder(lLeft, lTop, lRight, lBottom, cStyle, cColor)
 
    nRow := 12
    nCol := 1
    // blank - Usado somente para aplicar a formatação
    lRet := oPrtXlsx:ApplyFormat(nRow, nCol)
 
    nRow := 12
    nCol := 2
    // blank - Usado somente para aplicar a formatação
    lRet := oPrtXlsx:ApplyFormat(nRow, nCol)
 
    // cFont := FwPrinterFont():getFromName('code128b')
    cFont := FwPrinterFont():Code128b()
    nSize := 50
    lItalic := .F.
    lBold := .F.
    lUnderlined := .F.
    // Fonte Code 128 (para código de barras)
    lRet := oPrtXlsx:SetFont(cFont, nSize, lItalic, lBold, lUnderlined)
 
    nRow := 2
    nCol := 13
    // Texto para o código de barras Code128
    lRet := oPrtXlsx:SetText(nRow, nCol, "Ò,BX'hÓ")
 
    // cFont := FwPrinterFont():getFromName('qrcode')
    cFont := FwPrinterFont():QrCode()
    nSize := 50
    lItalic := .F.
    lBold := .F.
    lUnderlined := .F.
    // Fonte QRCode (para código de barras 2D)
    lRet := oPrtXlsx:SetFont(cFont, nSize, lItalic, lBold, lUnderlined)
 
    nRow := 6
    nCol := 13
    // Texto para o código de barras QRCode
    lRet := oPrtXlsx:SetText(nRow, nCol, "QRCode gerado para o Excel")
 
    // cFont := FwPrinterFont():getFromName('datamatrix')
    cFont := FwPrinterFont():DataMatrix()
    nSize := 50
    lItalic := .F.
    lBold := .F.
    lUnderlined := .F.
    // Fonte DataMatrix (para código de barras 2D)
    lRet := oPrtXlsx:SetFont(cFont, nSize, lItalic, lBold, lUnderlined)
 
    nRow := 11
    nCol := 13
    // Texto para o código de barras Datamatrix
    lRet := oPrtXlsx:SetText(nRow, nCol, "Datamatrix gerado para o Excel")
 
    // cFont := FwPrinterFont():getFromName('PDF417')
    cFont := FwPrinterFont():PDF417()
    nSize := 300
    lItalic := .T.
    lBold := .F.
    lUnderlined := .F.
    // Fonte PDF417 (para código de barras 2D)
    lRet := oPrtXlsx:SetFont(cFont, nSize, lItalic, lBold, lUnderlined)
 
    nRow := 16
    nCol := 13
    // Texto para o código de barras PDF417
    lRet := oPrtXlsx:SetText(nRow, nCol, "PDF417 gerado para o Excel")
 
    // cFont := FwPrinterFont():getFromName('calibri')
    cFont := FwPrinterFont():Calibri()
    nSize := 11
    lItalic := .F.
    lBold := .F.
    lUnderlined := .F.
    // Calibri 11
    lRet := oPrtXlsx:SetFont(cFont, nSize, lItalic, lBold, lUnderlined)
 
    nRow := 23
    nCol := 13
    cContent := "01005000000001001010111010001010111000111011101000101000111010111000101000111011100010101000111000101010111000111010"
    lRet := oPrtXlsx:SetVerticalBarCodeContent(nRow, nCol, cContent) // Comando 'Código de barra vertical'
 
    // Nova página
    lRet := oPrtXlsx:AddSheet("Minha Plan2")
 
    cHorAlignment := oCellHorAlign:Center()
    cVertAlignment := oCellVertAlign:Center()
    lWrapText := .F.
    nRotation := 270
    cCustomFormat := ""
    // Seta texto vermelho com alinhamento horizontal e vertical centralizado e com rotação de texto vertical
    lRet := oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, lWrapText, nRotation, "FF0000", "FFFFFF", cCustomFormat)
 
    nRowFrom := 2
    nColFrom := 2
    nRowTo := 21
    nColTo := 3
    // Mescla intervalo B2:C21
    lRet := oPrtXlsx:MergeCells(nRowFrom, nColFrom, nRowTo, nColTo)
 
    nRow := 2
    nCol := 2
    // Texto das células mescladas (apontando sempre para a primeira célula do intervalo)
    lRet := oPrtXlsx:SetText(nRow, nCol, "Células Mescladas")
 
    lTop := .T.
    lBottom := .T.
    lLeft:= .F.
    lRight := .F.
    cStyle := FwXlsxBorderStyle():Medium()
    cColor := "0000FF"
    // Borda azul, superior e inferior
    lRet := oPrtXlsx:SetBorder(lLeft, lTop, lRight, lBottom, cStyle, cColor)
 
    cHorAlignment := oCellHorAlign:Default()
    cVertAlignment := oCellVertAlign:Default()
    lWrapText := .T.
    nRotation := 0
    cCustomFormat := ""
    // Seta texto texto com quebra de linha
    lRet := oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, lWrapText, nRotation, "000000", "FFFFFF", cCustomFormat)
 
    nRow := 24
    nCol := 2
    // Texto da célula com borda
    lRet := oPrtXlsx:SetText(nRow, nCol, "Texto com quebra de linha")
 
    nRowFrom := 26
    nRowTo := 30
    nHeight := 18.75
    // Altura 18,75 nas linhas 26 a 30
    lRet := oPrtXlsx:SetRowsHeight(nRowFrom, nRowTo, nHeight)
    // Largura 23,71
    lRet := oPrtXlsx:SetColumnsWidth(5, 10, 23.71)
 
    lRet := oPrtXlsx:ResetBorder()
    // Limpa o formato
    lRet := oPrtXlsx:ResetCellsFormat()
 
    // Nova planilha
    // Pequena planilha para testar o AutoFiltro
    lRet := oPrtXlsx:AddSheet("AutoFiltro")
 
    jFontHeader := FwXlsxPrinterConfig():MakeFont()
    jFontHeader['font'] := FwPrinterFont():TimesNewRoman()
    jFontHeader['size'] := 15
    jFontHeader['bold'] := .T.
    jFontHeader['underline'] := .T.
 
    jFontNum := FwXlsxPrinterConfig():MakeFont()
    jFontNum['font'] := FwPrinterFont():CourierNew()
    jFontNum['size'] := 12
 
    jFontText := FwXlsxPrinterConfig():MakeFont()
    jFontText['font'] := FwPrinterFont():ArialBlack()
    jFontText['size'] := 12
    jFontText['italic'] := .T.
 
    jFormat := FwXlsxPrinterConfig():MakeFormat()
    jFormat['hor_align'] := oCellHorAlign:Center()
    jFormat['vert_align'] := oCellVertAlign:Center()
 
    // Bordas para o header
    jBorderHeader := FwXlsxPrinterConfig():MakeBorder()
    jBorderHeader['top'] := .T.
    jBorderHeader['bottom'] := .T.
    jBorderHeader['border_color'] := "B1B1B1"
    jBorderHeader['style'] := FwXlsxBorderStyle():Double()
 
    jBorderLeft := FwXlsxPrinterConfig():MakeBorder()
    jBorderLeft['left'] := .T.
    jBorderLeft['border_color'] := "FF0000"
    jBorderLeft['style'] := FwXlsxBorderStyle():Dashed()
     
    jBorderCenter := FwXlsxPrinterConfig():MakeBorder()
    jBorderCenter['left'] := .T.
    jBorderCenter['right'] := .T.
    jBorderCenter['border_color'] := "00FF00"
    jBorderCenter['style'] := FwXlsxBorderStyle():Dashed()
     
    jBorderRight := FwXlsxPrinterConfig():MakeBorder()
    jBorderRight['right'] := .T.
    jBorderRight['border_color'] := "0000FF"
    jBorderRight['style'] := FwXlsxBorderStyle():Dashed()
 
    // formatação para todas as células a seguir
    lRet := oPrtXlsx:SetCellsFormatConfig(jFormat)
 
    // fonte e borda para o cabeçalho
    lRet := oPrtXlsx:SetFontConfig(jFontHeader)
    lRet := oPrtXlsx:SetBorderConfig(jBorderHeader)
    lRet := oPrtXlsx:SetValue(1, 2, "Produto") // A1
    lRet := oPrtXlsx:SetValue(1, 3, "Mês")
    lRet := oPrtXlsx:SetValue(1, 4, "Total")
 
    // fonte e borda para coluna esquerda
    lRet := oPrtXlsx:SetFontConfig(jFontNum)
    lRet := oPrtXlsx:SetBorderConfig(jBorderLeft)
    lRet := oPrtXlsx:SetValue(2, 2, 1)
    lRet := oPrtXlsx:SetValue(3, 2, 1)
    lRet := oPrtXlsx:SetValue(4, 2, 2)
    lRet := oPrtXlsx:SetValue(5, 2, 2)
    lRet := oPrtXlsx:SetValue(6, 2, 3)
    lRet := oPrtXlsx:SetValue(7, 2, 3)
     
    // fonte e borda para coluna central
    lRet := oPrtXlsx:SetFontConfig(jFontText)
    lRet := oPrtXlsx:SetBorderConfig(jBorderCenter)
    lRet := oPrtXlsx:SetValue(2, 3, "Janeiro")
    lRet := oPrtXlsx:SetValue(3, 3, "Março")
    lRet := oPrtXlsx:SetValue(4, 3, "Janeiro")
    lRet := oPrtXlsx:SetValue(5, 3, "Março")
    lRet := oPrtXlsx:SetValue(6, 3, "Fevereiro")
    lRet := oPrtXlsx:SetValue(7, 3, "Março")
 
// fonte e borda para coluna central
    jFormat['custom_format'] := "#,##0.00"
    lRet := oPrtXlsx:SetCellsFormatConfig(jFormat)
    lRet := oPrtXlsx:SetFontConfig(jFontNum)
    lRet := oPrtXlsx:SetBorderConfig(jBorderRight)
    lRet := oPrtXlsx:SetValue(2, 4, 1100.10)
    lRet := oPrtXlsx:SetValue(3, 4, 1150)
    lRet := oPrtXlsx:SetValue(4, 4, 1200.22)
    lRet := oPrtXlsx:SetValue(5, 4, 1150)
    lRet := oPrtXlsx:SetValue(6, 4, 1100.14)
    lRet := oPrtXlsx:SetValue(7, 4, 1100) // C7
 
    // Aplica auto filtro no intervalo A1:C7
    lRet := oPrtXlsx:ApplyAutoFilter(1,1,7,3)
 
    lRet := oPrtXlsx:toXlsx()
 
return
