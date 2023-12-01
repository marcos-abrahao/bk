#include "totvs.ch"
#include "protheus.ch"

/*/{Protheus.doc} PDFHtml
BK - Funções de agregação de PDF em um HTML

@Return
@author Marcos B. Abrahão
@since 01/12/23
@version P12
/*/

User Function PdfHtml(cEmpresa,aUrls)
Local cHtml     := ""
Local nI        := 0
Local cVarsUrls := ""
Local cLTasks   := ""
Local cRPages   := ""

BEGINCONTENT var cHTML

<script src="#ipserver#/mostra/pdfjs-dist/build/pdf.js"></script>

<script>
// Urls dos arquivos .pdf
#varurls#

// Carrega via <script> tag, cria endereço para acesso ao PDF.js exports.
var pdfjsLib = window['pdfjs-dist/build/pdf'];

// Local do dpf.worker.js
pdfjsLib.GlobalWorkerOptions.workerSrc = '#ipserver#/mostra/pdfjs-dist/build/pdf.worker.js';

// Asynchronous download do PDF
#loadingTasks#

function renderizaPagina(pageNumber,loadingTask,numpdf) {

    loadingTask.promise.then(function(pdf) {
        //console.log('PDF loaded');

        // Pega primeira page
        pdf.getPage(pageNumber).then(function(page) {
        console.log('Page loaded: '+ pageNumber );

        var scale = 1.2;
        var viewport = page.getViewport({scale: scale});
		var ecanvas = 'the-canvas'+numpdf
		//console.log('ecanvas: '+ ecanvas );

        // Prepara canvas usando as dimensões da página PDF
        var canvas = document.getElementById(ecanvas);
        var context = canvas.getContext('2d');
        canvas.height = viewport.height;
        canvas.width = viewport.width;

        // Renderiza página PDF para canvas
        var renderContext = {
        canvasContext: context,
        viewport: viewport
        };
        var renderTask = page.render(renderContext);

            renderTask.promise.then(function () {
            console.log('Página renderizada!');
        });
    });
    }, function (reason) {
    // Mostra erro
    console.error(reason);
    });
}

//mostra os arquivos .pdf
#renderpages#

</script>

ENDCONTENT


// Monta trecho com as vars urls dos pdfs
cVarsUrls := ""
For nI := 1 To Len(aUrls)
    cVarsUrls += "var url"+ALLTRIM(STR(nI))+" = '/dirdoc/co"+cEmpresa+"/shared/"+ aUrls[nI]+"';"+CRLF
Next

cLTasks := ""
For nI := 1 To Len(aUrls)
    cLTasks += "var loadingTask"+ALLTRIM(STR(nI))+" = pdfjsLib.getDocument(url"+ALLTRIM(STR(nI))+");"+CRLF
Next

cRPages := ""
For nI := 1 To Len(aUrls)
    cRPages += "pdfjsLib.getDocument(url"+ALLTRIM(STR(nI))+").promise.then(function(pdfDoc_) {"+CRLF
    cRPages += "    pdfDoc = pdfDoc_;"+CRLF
    cRPages += "    renderizaPagina(1,loadingTask"+ALLTRIM(STR(nI))+","+ALLTRIM(STR(nI))+");"+CRLF
    cRPages += "});"+CRLF
    /*
    pdfjsLib.getDocument(url1).promise.then(function(pdfDoc_) {
        pdfDoc = pdfDoc_;
        // Chamando a renderizacao da página 1
        renderizaPagina(1,loadingTask1,1);
    });

    pdfjsLib.getDocument(url2).promise.then(function(pdfDoc_) {
        pdfDoc = pdfDoc_;
        // Chamando a renderizacao da página 1
        renderizaPagina(1,loadingTask2,2);
    });
    */
Next


// Substituição dos trechos
cHtml := STRTRAN(cHtml,"#ipserver#",u_BkIpServer())
cHtml := STRTRAN(cHtml,"#varurls#",cVarsUrls)
cHtml := STRTRAN(cHtml,"#loadingTasks#",cLTasks)
cHtml := STRTRAN(cHtml,"#renderpages#",cRPages)

Return cHtml


// Css para usar com o PDF
User Function CssCanvas()
Local cCss := ""

BEGINCONTENT var cCss
#the-canvas {
  border: 1px solid black;
  direction: ltr;
}
ENDCONTENT

Return cCss
