`import Ember from 'ember'`
`/* global sprintf */`

ApplicationController = Ember.Controller.extend
  cnpj: 20495149000287 # Default: Prodoeste
  supplies: []

  suppliesToText: (->
    supplies = @get('supplies')
    cnpj = @get('cnpj')
    lines = []

    # Pushing header
    lines.push "INDICE   \tNUMABAST    \tVEICODIGO\tTPREG\tBOMBA\tREDE \tPOSTO\tFROTA\tC\tUVE \tPLACA  \tMOTORISTA           \tKM     \tQTD       \tPU       \tPUBRAD   \tTOTAL         \tDATA ABASTECIMENTO  \tDATA DEB  \tDATA CRED \tABTARQUIVO     \tDIST PERC\tCOMB TOTAL\tS\tCD_ABAT_ANTR_VEIC\tPOSTO FANTASIA    \tPOSTO CIDADE                            \tCGC                 \tDAT_ABASTECIMENTO_INICIO \tDAT_ABASTECIMENTO_FIM    \tCOD_MA"

    # Mounting lines
    for supply in supplies
      do(supply)->
        lines.push
        lines.push sprintf(
          "%1$-9s\t%1$-12s\t%2$-9s\t%2$-9s\t%2$-5s\t%2$-5s\t%2$-5s\t%2$-5s\t%2$-5s\t%2$-5s\t%3$1s\t%2$-4s\t%4$7s\t%5$-20s\t%6$-7s\t%7$-10s\t%8$-9s\t%8$-9s\t%9$-14s\t%10$-20s\t%11$-10s\t%11$-10s\t%12$-15s\t%2$-9s\t%7$-10s\t%13$1s\t%2$-17s\t%5$-18s\t%5$-40s\t%14$-20s\t%10$-25s\t%10$-25s",
          supply.coupon,
          '1',
          supply.fuel,
          supply.licensePlate,
          'LENARGE TRANSPORTES',
          supply.km,
          sprintf('%1$.2f', supply.qty),
          sprintf('%1$.3f', supply.unitValue),
          sprintf('%1$.2f', supply.totalValue),
          supply.date.format('DD/MM/YYYY HH:mm'),
          supply.date.format('DD/MM/YYYY'),
          'A',
          'S',
          sprintf("%1$'014d", cnpj)
          )

    lines.push('')
    lines.join('\r\n')
  ).property 'supplies', 'cnpj'

  reportURL: (->
    text = @get('suppliesToText')
    data = new Blob([text], {type: 'text/plain'})

    # If we are replacing a previously generated file we need to
    # manually revoke the object URL to avoid memory leaks.
    if textFile != null
      window.URL.revokeObjectURL textFile

    textFile = window.URL.createObjectURL(data)
  ).property 'suppliesToText'

`export default ApplicationController`
