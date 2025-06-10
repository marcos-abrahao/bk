#Include "Protheus.ch"
 
//-------------------------------------------------------------------
/*{Protheus.doc} BKESTR11
Termo de retirada de material - Barcas Rio - Via movimentação multipla
(Base: MATR107)

@author Marcos Bispo Abrahao
@since 31/05/2025
@version P12.00
*/

User Function BKESTR11
Local cHtml     := ""
Local aAreaSD3  := GetArea("SS3")
Private cProg   := "BKESTR11"

cHtml := HtmlR11(SD3->D3_DOC)

u_TmpHtml(cHtml,cProg,.T.)

SD3->(RestArea(aAreaSD3))

Return Nil



Static Function HtmlR11(cDocD3)
Local cHtml := ""
BEGINCONTENT var cHtml

<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Termo de Retirada</title>
<style>
    body {
        font-family: Arial, sans-serif;
        margin: 0;
        padding: 0;
        background-color: #f5f5f5;
    }
    .container {
        max-width: 800px;
        margin: 0 auto;
        padding: 20px;
    }
    .form-group {
        margin-bottom: 15px;
    }
    label {
        display: block;
        margin-bottom: 5px;
        font-weight: bold;
    }
    input[type="text"], input[type="date"], textarea {
        width: 100%;
        padding: 8px;
        border: 1px solid #ddd;
        border-radius: 4px;
        box-sizing: border-box;
    }
    .btn-container {
        text-align: center;
        margin: 20px 0;
    }
    .btn {
        padding: 10px 20px;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        font-size: 16px;
        margin: 0 10px;
    }
    .btn-pdf {
        background-color: #9E0000;
        color: white;
    }
    .btn-pdf:hover {
        background-color: #7A0000;
    }
    .btn-reset {
        background-color: #333;
        color: white;
    }
    .btn-reset:hover {
        background-color: #111;
    }
    .termo-container {
        background-color: white;
        padding: 30px;
        box-shadow: 0 0 10px rgba(0,0,0,0.1);
        margin-bottom: 30px;
        position: relative;
    }
    .header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
        border-bottom: 1px solid #ddd;
        padding-bottom: 15px;
    }
    .logo {
        max-height: 70px;
    }
    .header-info {
        text-align: right;
        font-size: 12px;
        color: #555;
    }
    h1 {
        text-align: center;
        font-size: 18px;
        margin: 30px 0;
        color: #333;
    }
    .declaracao {
        margin: 30px 0;
        line-height: 1.8;
        font-size: 14px;
    }
    .campo-preenchimento {
        display: inline-block;
        vertical-align: bottom;
        border-bottom: none;
        font-weight: bold;
    }
    .campo-preenchimento:empty {
        min-width: 250px;
        border-bottom: 1px solid #000;
        padding-bottom: 8px;
    }
    .campo-cpf {
        display: inline-block;
        vertical-align: bottom;
        border-bottom: none;
        font-weight: bold;
    }
    .campo-cpf:empty {
        min-width: 200px;
        border-bottom: 1px solid #000;
        padding-bottom: 8px;
    }

    table {
        width: 100%;
        border-collapse: collapse;
        margin: 25px 0;
        font-size: 12px;
    }
    th, td {
        border: 1px solid #ddd;
        padding: 8px;
        text-align: left;
    }
    th {
        background-color: #f2f2f2;
        font-weight: bold;
    }
    .info-adicional {
        margin: 20px 0;
        font-size: 14px;
    }
    .info-linha {
        display: flex;
        margin-bottom: 8px;
    }
    .info-label {
        display: inline-block;
        font-weight: bold;
        min-width: 180px;
    }
    .info-valor {
        margin-right: 30px;
        min-width: 150px;
        font-weight: bold;
    }
  
   .signatures-cidade {
      display: flex;
      margin-top: 20px;
      flex-wrap: nowrap;
      font-size: 12px;
   } 

    .signatures-container {
       display: flex;
       justify-content: space-between;
       margin-top: 50px;
       flex-wrap: nowrap;
   }
   .signature-box {
       text-align: center;
       width: 23%;
       min-width: 150px;
   }
   .signature-line {
       border-top: 1px solid #000;
       width: 90%;
       margin: 0 auto;
       padding-top: 0px;
       height: 0px;
   }

    .header img {
        max-width: 300px;
        max-height: 80px;
        width: auto;
        height: auto;
        object-fit: contain;
    }
    /* Controle de quebra de página */
     @media print {
       .termo-container {
           position: relative;
       }
       
    }
</style>
</head>
<body>
    <div class="container">
        <div class="form-container">
            <h2>Preencha os Dados do Termo</h2>
            
            <div class="form-group">
                <label for="nome-responsavel">Nome do Responsável:</label>
                <input type="text" id="nome-responsavel" placeholder="Digite o nome completo">
            </div>
            
            <div class="form-group">
                <label for="cpf-number">Número do CPF:</label>
                <input type="text" id="cpf-number" placeholder="Digite o número do CPF">
            </div>
            
            <div class="form-group">
                <label for="ordem-servico">Ordem de Serviço:</label>
                <input type="text" id="ordem-servico" placeholder="Digite o numero da ordem de serviço do Helm">
            </div>

        </div>

        <div class="btn-container">
            <button class="btn btn-pdf" id="gerar-pdf">Gerar PDF</button>
            <button class="btn btn-reset" id="limpar-form">Limpar Formulário</button>
        </div>

        <div class="termo-container" id="termo-pdf">

            <div class="header">
                <!-- ##logo## -->
                <img src="##bksrvweb##/logos/lgmid##empant##.png" class="logo" alt="Logo">
                <div class="header-info">
                    Termo de Retirada/BKESTR11<br>
                    Hora: <span id="current-time"></span><br>
                    Empresa: ##empresa##
                </div>
            </div>            

            <h1>TERMO DE RETIRADA</h1>

            <div class="info-adicional avoid-break">
                <div class="info-linha">
                    <span class="info-label">Data de Emissão:</span>
                    <span class="info-valor" id="data-emissao-texto">##dataemissao##</span>
                </div>
                <div class="info-linha">
                    <span class="info-label">Solicitante:</span>
                    <span class="info-valor" id="solicitante-texto">##solicitante##</span>
                </div>
                
                <div class="info-linha">
                    <span class="info-label">Documento:</span>
                    <span class="info-valor" id="numero-solicitacao-texto">##solicitacao##</span>
                </div>
                <div class="info-linha">
                    <span class="info-label">Tipo de requisição:</span>
                    <span class="info-valor" id="tipo-armazenamento-texto">##tipoarmaz##</span>
                </div>
                
                <div class="info-linha">
                    <span class="info-label">Centro de Custos:</span>
                    <span class="info-valor" id="centro-custo-texto">##centrodecustos##</span>
                </div>
                <div class="info-linha">
                    <span class="info-label">Ordem de Serviço:</span>
                    <span class="info-valor" id="ordem-servico-texto">##oshelm##</span>
                </div>
            </div>

            <div class="declaracao">
                <p>Eu, <span id="responsavel-texto" class="campo-preenchimento"></span>, portador do CPF de número <span id="cpf-texto" class="campo-cpf"></span>, confirmo o recebimento dos itens discriminados abaixo na presente data e em condições adequadas para utilização.</p>
            </div>

            ##tabela-itens##

            <div class="signatures-cidade">
               ##cidade##, <span id="current-date"></span>
            </div>

            <div class="signatures-container">
                <div class="signature-box">
                    <div class="signature-line"></div>
                    <div style="margin-top: 5px;">Solicitante</div>
                </div>
                <div class="signature-box">
                    <div class="signature-line"></div>
                    <div style="margin-top: 5px;">Gestor</div>
                </div>
                <div class="signature-box">
                    <div class="signature-line"></div>
                    <div style="margin-top: 5px;">Usuário</div>
                </div>
                <div class="signature-box">
                    <div class="signature-line"></div>
                    <div style="margin-top: 5px;">Recebedor</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Inclui a biblioteca html2pdf -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
    
<script>
    // Atualiza data e hora atuais
    function updateDateTime() {
        const now = new Date();
        const options = { day: '2-digit', month: 'long', year: 'numeric' };
        document.getElementById('current-date').textContent = now.toLocaleDateString('pt-BR', options);
        
        const timeOptions = { hour: '2-digit', minute: '2-digit', second: '2-digit' };
        document.getElementById('current-time').textContent = now.toLocaleTimeString('pt-BR', timeOptions);
        
        // Define a data atual como padrão para o campo de data
        //document.getElementById('data-emissao').valueAsDate = now;
    }
    
    // Atualiza os campos do termo com os valores do formulário
    function updateTermo() {
        const nome = document.getElementById('nome-responsavel').value;
        const cpf = document.getElementById('cpf-number').value;
        //const ordemsvr = document.getElementById('ordem-servico').value;

        // Atualiza campos com valores ou deixa vazio para preenchimento manual
        document.getElementById('responsavel-texto').textContent = nome || '';
        document.getElementById('cpf-texto').textContent = cpf || '';
        //document.getElementById('ordem-servico-texto').textContent = ordemsvr || '';
       
    }
    
    // Preenche os campos programáticos
    /*
    function preencherCamposProgramaticos() {
        // Exemplo - substitua por seus valores reais
        document.getElementById('solicitante-texto').textContent = "##solicitante##";
        document.getElementById('numero-solicitacao-texto').textContent = "##solicitacao##";
        document.getElementById('tipo-armazenamento-texto').textContent = "##tipoarmaz##";
        document.getElementById('centro-custo-texto').textContent = "##centrodecustos##";
        //document.getElementById('ordem-servico-texto').textContent = "OS-5678";
    }
    */
   // Configura o botão de gerar PDF
      document.getElementById('gerar-pdf').addEventListener('click', () => {
      updateTermo();
      
      const element = document.getElementById('termo-pdf');
      const opt = {
          margin: [10, 15, 20, 15],
          filename: 'Termo_de_Retirada.pdf',
          image: { type: 'jpeg', quality: 0.98 },
          html2canvas: { 
              scale: 2,
              logging: true,
              useCORS: true,
              letterRendering: true,
              allowTaint: true
          },
          jsPDF: { 
              unit: 'mm', 
              format: 'a4', 
              orientation: 'portrait',
              compress: true
          },
          pagebreak: { 
              mode: ['css', 'legacy'],
              before: '.force-page-break',
              avoid: ['.avoid-break', 'tr', '.signatures-container']
          },

          onPage: function(pageNum, numPages) {
              // Atualiza a numeração em todos os rodapés
              const footers = document.querySelectorAll('.footer');
              footers.forEach(footer => {
                  const pageNumber = footer.querySelector('.page-number');
                  if (pageNumber) {
                      pageNumber.textContent = `Página ${pageNum} de ${numPages}`;
                  }
              });
          }
      };
  
      // Mostra mensagem enquanto gera
      const originalText = document.getElementById('gerar-pdf').textContent;
      document.getElementById('gerar-pdf').textContent = 'Gerando PDF...';
      document.getElementById('gerar-pdf').disabled = true;
      
      // Gera o PDF
      html2pdf().set(opt).from(element).save().then(() => {
          document.getElementById('gerar-pdf').textContent = originalText;
          document.getElementById('gerar-pdf').disabled = false;
      });
    });
    // Configura o botão de limpar formulário
    document.getElementById('limpar-form').addEventListener('click', () => {
        document.getElementById('nome-responsavel').value = '';
        document.getElementById('cpf-number').value = '';
        document.getElementById('ordemservico').value = '';
        updateTermo();
    });
    
    // Atualiza os campos em tempo real enquanto digita
    document.getElementById('nome-responsavel').addEventListener('input', updateTermo);
    document.getElementById('cpf-number').addEventListener('input', updateTermo);
    document.getElementById('ordem-servico').addEventListener('input', updateTermo);
    
   // Função para garantir alinhamento dos campos
    function alinharCamposPreenchidos() {
        document.querySelectorAll('.info-valor').forEach(campo => {
            if (campo.textContent.trim() === '') {
                campo.style.borderBottom = '1px solid #000';
                campo.style.minHeight = '20px';
            } else {
                campo.style.borderBottom = 'none';
            }
        });
    }

    // Chamar esta função após preencher os campos
    window.onload = function() {
        updateDateTime();
        //preencherCamposProgramaticos();
        alinharCamposPreenchidos();
    };

</script>

</body>
</html>

ENDCONTENT

cHtml := STRTRAN(cHtml,"##empresa##",ALLTRIM(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , {"M0_NOME"} )[1,2]))
cHtml := STRTRAN(cHtml,"##cidade##",ALLTRIM(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , {"M0_CIDENT"} )[1,2]))
cHtml := STRTRAN(cHtml,"##bksrvweb##",u_BkSrvWeb())
cHtml := STRTRAN(cHtml,"##empant##",cEmpAnt)

cHtml := STRTRAN(cHtml,"##dataemissao##",DTOC(SD3->D3_EMISSAO))
cHtml := STRTRAN(cHtml,"##solicitante##",SD3->D3_USUARIO)
cHtml := STRTRAN(cHtml,"##solicitacao##",SD3->D3_DOC)
If u_IsBarcas(cEmpAnt)
    cHtml := STRTRAN(cHtml,"##tipoarmaz##",X3COMBO('D3_XTRQSC',SD3->D3_XTRQSC))
    cHtml := STRTRAN(cHtml,"##oshelm##",SD3->D3_XOSHELM)
Else
    cHtml := STRTRAN(cHtml,"##tipoarmaz##","")
    cHtml := STRTRAN(cHtml,"##oshelm##","")
EndIf

cHtml := STRTRAN(cHtml,"##centrodecustos##",SD3->D3_CC)

cHtml := STRTRAN(cHtml,"##tabela-itens##",TabItens(cDocD3))

cHtml := StrIConv( cHtml, "CP1252", "UTF-8")
cHtml := u_BKUtf8()+cHtml

Return cHtml



Static Function TabItens(cDocD3)
Local cTab   := ""
Local cCab   := ""
Local nTamQ  := TamSX3("D3_QUANT")[1]
Local nDecQ  := TamSX3("D3_QUANT")[2]
Local nItem  := 1
Local nPag   := 1
Local nTamPg := 13
Local nItens := 0

cTab += '<table class="avoid-break">' + CRLF
cCab += "<thead>" + CRLF
cCab += "<tr>" + CRLF
cCab += "<th>Item</th>" + CRLF
cCab += "<th>Cod. Prod.</th>" + CRLF
cCab += "<th>Produto</th>" + CRLF
cCab += "<th>U.M.</th>" + CRLF
cCab += "<th>Quant.</th>" + CRLF
cCab += "<th>Local</th>" + CRLF
cCab += "</tr>" + CRLF
cCab += "</thead>" + CRLF
cCab += "<tbody>" + CRLF
cTab += cCab

dbSelectArea("SD3")
dbSetOrder(2)
dbSeek(xFilial("SD3")+cDocD3,.T.)
Do While cDocD3 == SD3->D3_DOC .AND. !EOF()
    dbSkip()
    nItens++
EndDo
If nItens > (nTamPg + 3)
    nTamPg := + 3
EndIf

dbSelectArea("SD3")
dbSetOrder(2)
dbSeek(xFilial("SD3")+cDocD3,.T.)
Do While cDocD3 == SD3->D3_DOC .AND. !EOF()
    cTab += "<tr>" + CRLF
    cTab += "<td>" + AllTrim(SD3->D3_ITEM) +"</td>" + CRLF
    cTab += "<td>" + AllTrim(SD3->D3_COD) +"</td>" + CRLF
    cTab += "<td>" + AllTrim(TRIM(Posicione("SB1",1,xFilial("SB1")+SD3->D3_COD,"B1_DESC"))) +"</td>" + CRLF
    cTab += "<td>" + AllTrim(SD3->D3_UM) +"</td>" + CRLF
    cTab += "<td>" + AllTrim(STR(SD3->D3_QUANT,nTamQ,nDecQ)) +"</td>" + CRLF
    cTab += "<td>" + AllTrim(SD3->D3_LOCAL) +"</td>" + CRLF
    cTab += "</tr>" + CRLF
    dbSkip()
    nItem++
    If nPag > 1
        nTamPg := 20
    EndIf
    If !SD3->(Eof()) .AND. nItem > nTamPg
        nItem := 1
        nPag++
        cTab += "</tbody>" + CRLF
        cTab += "</table>" +CRLF
        cTab += '<table class="force-page-break">' +CRLF
        cTab += cCab
    EndIf
EndDo
cTab += "</tbody>" + CRLF
cTab += "</table>" + CRLF

Return cTab
                
            

