`import Ember from 'ember'`
`/*globals XLSX, XLSXWorkbook, moment*/`

SpreadsheetReaderComponent = Ember.Component.extend {
  classNames: ['drag-n-drop']
  workbook: null
  supplies: null

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
      for row in [1..rowsCount]
        do (row)->
          # parse each row and add to supplies
          supplies[row] = self.parseRow(row)

    supplies

  # returns supply object
  parseRow: (rowNum)->
    row = @row(rowNum)

    {
      date:         moment(row['date'].w, 'MM/DD/YYYY HH:mm')
      coupon:       row['coupon'].w
      fuel:         row['fuel']
      qty:          row['qty']
      unitValue:    row['unitValue']
      totalValue:   row['totalValue']
      licensePlate: row['licensePlate']
      km:           row['km']
    }

  updateSupplies: (->
    @set 'supplies', @parseSheet()
  ).property('sheet', 'rowsCount')

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
}

`export default SpreadsheetReaderComponent`
