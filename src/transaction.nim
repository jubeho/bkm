# module transaction
import std/[tables,times,strutils,logging,parsecsv,strformat]

const
  cSep = ';'

type
  Transaction* = ref object
    id*: string # IBAN Auftragskonto|buchungstag|valutadatum|IBAN Zahlungsbeteiligter|Betrag
    accountSrc*: string # Bezeichnung Auftragskonto
    ibanSrc*: string # IBAN Auftragskonto
    bicSrc*: string # BIC Auftragskonto
    bankName*: string # Bankname Auftragskonto
    # bookingDay: DateTime # Buchungstag
    # valutaDate: DateTime # Valutadatum
    bookingDay*: string # Buchungstag
    valutaDate*: string # Valutadatum
    nameTarget*: string # Name Zahlungsbeteiligter
    ibanTarget*: string #  Zahlungsbeteiligter
    bicTarget*: string # BIC (SWIFT-Code) Zahlungsbeteiligter
    bookingText*: string # Buchungstext
    whatFor*: string # Verwendungszweck
    # amount: string # Betrag
    amount*: float # Betrag
    currency*: string # Waehrung
    afterBookingAmount*: float #Saldo nach Buchung
    # afterBookingAmount: string #Saldo nach Buchung
    comment*: string # Bemerkung
    category*: string # Kategorie
    tax*: string # Steuerrelevant
    destId*: string # Glaeubiger ID
    mRef*: string # Mandatsreferenz

proc newTransaction*(row, header: seq[string]): Transaction
proc parseCsvFile*(fp: string, headerIdx: int = 0,): Table[string, Transaction]
proc importCsvFile*(fp: string, headerIdx: int = 0, transactions: var Table[string, Transaction])
    
proc newTransaction*(row, header: seq[string]): Transaction =
  if len(row) != len(header):
    echo "row and header are from different length: row(" & $len(row) & "), header(" & $len(header) & ")"
    return nil
  result = Transaction()
  for i in 0..len(row)-1:
    case header[i]
    of "Bezeichnung Auftragskonto":
      result.accountSrc = row[i]
    of "IBAN Auftragskonto":
      result.ibanSrc = row[i]
    of "BIC Auftragskonto":
      result.bicSrc = row[i]
    of "Bankname Auftragskonto":
      result.bankName = row[i]
    of "Buchungstag":
      # result.bookingDay = now()
      result.bookingDay = row[i]
    of "Valutadatum":
      # result.valutaDate = now()
      result.valutaDate = row[i]
    of "Name Zahlungsbeteiligter":
      result.nameTarget = row[i] 
    of "Zahlungsbeteiligter":
      result.ibanTarget = row[i]
    of "BIC (SWIFT-Code) Zahlungsbeteiligter":
      result.bicTarget = row[i]
    of "Buchungstext":
      result.bookingText = row[i] 
    of "Verwendungszweck":
      result.whatFor = row[i]
    of "Betrag":
      try:
        result.amount = row[i].replace(',','.').parseFloat()
      except:
        error(fmt("can not parse Float of Betrag {row[i]}"))
        result.amount = 0.0
    of "Waehrung":
      result.currency = row[i]
    of "Saldo nach Buchung":
      try:
        result.afterBookingAmount = row[i].replace(',','.').parseFloat()
      except:
        error(fmt("can not parse Float of Betrag '{row[i]}'"))
        result.afterBookingAmount = -0.0
    of "Bemerkung":
      result.comment = row[i]
    of "Kategorie":
      result.category = row[i]
    of "Steuerrelevant":
      result.tax = row[i]
    of "Glaeubiger ID":
      result.destId = row[i]
    of "Mandatsreferenz":
      result.mRef = row[i] 
    else:
      continue
  #ta.id = ta.accountSrc & "|" & $ta.bookingDay
    result.id = result.ibanSrc & "|" & $result.bookingDay & "|" & $result.valutaDate & "|" & result.ibanTarget & "|" & $result.amount

proc parseCsvFile*(fp: string, headerIdx: int = 0): Table[string, Transaction] =
  info("not implemented yet")
  
proc importCsvFile*(fp: string, headerIdx: int = 0, transactions: var Table[string, Transaction]) =
  var csvpars: CsvParser
  csvpars.open(fp, cSep)
  defer: csvpars.close()

  var header: seq[string] = @[]
  var rowCount = -1
  while csvpars.readRow():
    inc(rowCount)
    if rowCount < headerIdx:
      continue
    if rowCount == headerIdx:
      header = csvpars.row
      continue
    let ta = newTransaction(csvpars.row, header)
    if hasKey(transactions, ta.id):
      debug(fmt("Transaction {ta.id} already exists in transactions"))
      continue
    transactions[ta.id] = ta
  
proc transactionToSeq*(ta: Transaction): seq[string] =
  result.add(ta.accountSrc)
  result.add(ta.ibanSrc)
  result.add(ta.bicSrc)
  result.add(ta.bankName)
  result.add(ta.bookingDay)
  result.add(ta.valutaDate)
  result.add(ta.nameTarget)
  result.add(ta.ibanTarget)
  result.add(ta.bicTarget)
  result.add(ta.bookingText)
  result.add(ta.whatFor)
  result.add($ta.amount)
  result.add(ta.currency)
  result.add($ta.afterBookingAmount)
  result.add(ta.comment)
  result.add(ta.category)
  result.add(ta.tax)
  result.add(ta.destId)
  result.add(ta.mRef )
    
