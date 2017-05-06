import nimx.view
import nimx.font
import nimx.app
import nimx.table_view
import nimx.text_field
import nimx.window
import nimx.linear_layout
import nimx.formatted_text
import nimx.system_logger # Required because of Nim bug (#4433)
import os
import sequtils
import intsets
import nimx.button
import nimx.types
import strutils
import typetraits
import nimx.context

type SampleInfo = tuple[name: string, className: string]

var allSamples* = newSeq[SampleInfo]()

template registerSample*(T: typedesc, sampleName: string) =
    allSamples.add((sampleName, name(T)))
    registerClass(T)

type ControlsSampleView = ref object of View

const primer = "enter a bash command"

method init(v: ControlsSampleView, r: Rect) =
    procCall v.View.init(r)

    #let textField = TextField.new(v.bounds.inset(50, 50))
    let textField = newTextField(newRect(20, 20, v.bounds.width - 50, 30))
    textField.resizingMask = "wh"
    textField.text = primer
    #textField.backgroundColor = newColor(0.5, 0, 0, 0.5)
    textField.multiline = false

    let label2 = newLabel(newRect(10, 70, 80, 20))
    label2.text = "exit code: "
    textField.formattedText.setFontInRange(0, textField.text.len, systemFontOfSize(20))
        #textField.formattedText.setShadowInRange(a, b, newColor(0.0, 0.0, 1.0, 1.0), newSize(2, 2), 1.0, 0.8)
    textField.autoresizingMask = { afFlexibleWidth, afFlexibleMaxY }
    v.addSubview(label2)
    v.addSubview(textField)

    textField.onAction do():
        label2.text = "exit code: " & (if textField.text.isNil: "nothing entered." else: intToStr(execShellCmd("ion -c \"" & textField.text & "\" > ~/.ionbar.log"), 1)) ## use nohup .. & ? log??
    ## TODO cli options to set the shell?

    v.addSubview(textField)

registerSample(ControlsSampleView, "Controls")
proc startApplication() =

    var mainWindow : Window

    mainWindow = newWindow(newRect(40, 40, 550, 70))

    mainWindow.title = "bash-bar"

    var currentView = View.new(newRect(0, 0, mainWindow.bounds.width, mainWindow.bounds.height))

    let splitView = newHorizontalLayout(mainWindow.bounds)
    splitView.resizingMask = "wh"
    splitView.userResizeable = true
    mainWindow.addSubview(currentView)
    let tableView = newTableView(newRect(0, 0, 0, mainWindow.bounds.height))
    tableView.resizingMask = "rh"
    splitView.addSubview(currentView)

    tableView.numberOfRows = proc: int = allSamples.len
    tableView.createCell = proc (): TableViewCell =
        result = newTableViewCell(newLabel(newRect(0, 0, 0, 20)))
    tableView.configureCell = proc (c: TableViewCell) =
        TextField(c.subviews[0]).text = allSamples[c.row].name
    tableView.onSelectionChange = proc() =
        let selectedRows = toSeq(items(tableView.selectedRows))
        if selectedRows.len > 0:
            let firstSelectedRow = selectedRows[0]
            let nv = View(newObjectOfClass(allSamples[firstSelectedRow].className))
            nv.init(currentView.frame)
            nv.resizingMask = "wh"
            splitView.replaceSubview(currentView, nv)
            currentView = nv

    tableView.reloadData()
    tableView.selectRow(0)

runApplication:
    startApplication()
