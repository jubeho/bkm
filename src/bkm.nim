import std/[logging,tables,strformat,os]
import transaction

type
  BkmData* = ref object
    transactions*: Table[string,Transaction]
    # transactions*: Table[string,string]

proc newBkmData*(): BkmData
proc loadTransactions*()
proc importFiles*(args: seq[string])

proc newBkmData*(): BkmData =
  result = BkmData()

proc importFiles*(args: seq[string]) =
  var tas = initTable[string, Transaction]()
  for arg in args:
    info(fmt("import file {arg} into bkm-data..."))
    # TODO go into dirs and search for csv...
    let fi = getFileInfo(arg)
    if fi.kind != pcFile:
      warn(fmt("cannot work on {arg} because it is not a file..."))
      continue
    info(fmt("read in file {arg}..."))
    importCsvFile(arg, 0, tas)

proc loadTransactions*() =
  discard
