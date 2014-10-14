`import Ember from 'ember'`
`/*globals XLSX, XLSXWorkbook, moment*/`

SpreadsheetReaderComponent = Ember.Component.extend {
  classNames: ['drag-n-drop']
  classNameBindings: ['hasSupplies']
  workbook: null
  supplies: null

  hasSupplies: (->
    supplies = @get('supplies')
    !!supplies && supplies.length > 0
  ).property('supplies')

  sheet: (->
    workbook = @get('workbook')
    workbook.Sheets[workbook.SheetNames[0]]
  ).property 'workbook'

  rowsCount: (->
    sheet = @get('sheet')
    XLSX.utils.decode_range(sheet["!ref"]).e.r
  ).property 'sheet'

  row: (n)->
    sheet = @get('sheet')

    {
      date:         sheet['A' + n]
      coupon:       sheet['B' + n]
      fuel:         sheet['C' + n]
      qty:          sheet['D' + n]
      unitValue:    sheet['E' + n]
      totalValue:   sheet['F' + n]
      licensePlate: sheet['G' + n]
      km:           sheet['H' + n]
    }

  parseSheet: ->
    supplies = []
    rowsCount = @get('rowsCount')
    self = @

    # iterate on sheet rows skipping header [0]
    if rowsCount > 0
      for row in [2..rowsCount+1]
        do (row)->
          # parse each row and add to supplies
          supplies[row-2] = self.parseRow(row)

    supplies

  # returns supply object
  parseRow: (rowNum)->
    row = @row(rowNum)

    {
      date:         moment(row['date'].w, 'MM/DD/YY HH:mm')
      coupon:       row['coupon'].w
      fuel:         @parseFuel(row['fuel'].v)
      qty:          row['qty'].v
      unitValue:    row['unitValue'].v
      totalValue:   row['totalValue'].v
      licensePlate: row['licensePlate'].v.replace(' ', '').replace('-', '')
      km:           row['km'].v
    }

  parseFuel: (fuelText)->
    if fuelText.match(/DIESEL/i)
      return "A" if fuelText.match(/COMUM|500/i)
      return "S" if fuelText.match(/10/)
    else if fuelText.match(/GAS/i)
      return "B"

  dragOver: (ev) ->
    ev.preventDefault()

  drop: (ev) ->
    ev.stopPropagation()
    ev.preventDefault()

    file = ev.dataTransfer.files[0] # read only first workbook
    reader = new FileReader()

    self = @
    reader.onload = (f) ->
      self.set 'workbook', XLSX.read(f.target.result, type: 'binary')
      # console.log self # XLSX.read(f.target.result, type: 'binary')

    reader.readAsBinaryString(file)


  actions:
    readReport: ->
      if !!@get('workbook')
        @set 'supplies', @parseSheet()
      else
        alert 'Drop an report before'
}

`export default SpreadsheetReaderComponent`
