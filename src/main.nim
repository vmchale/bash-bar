import nimx.view
import nimx.app
import nimx.table_view
import nimx.text_field
import nimx.window
import nimx.linear_layout
import nimx.system_logger # Required because of Nim bug (#4433)
import os
import sequtils
import intsets
import nimx.button
import nimx.types
import strutils
import typetraits

type SampleInfo = tuple[name: string, className: string]

var allSamples* = newSeq[SampleInfo]()

template registerSample*(T: typedesc, sampleName: string) =
    allSamples.add((sampleName, name(T)))
    registerClass(T)


type ControlsSampleView = ref object of View

method init(v: ControlsSampleView, r: Rect) =
    procCall v.View.init(r)

    let label = newLabel(newRect(10, 10, 100, 20))
    label.text = "Bash command:"
    let label2 = newLabel(newRect(10, 100, 100, 20))
    label2.text = "exit code: "
    let textField = newTextField(newRect(120, 10, v.bounds.width - 130, 20))
    textField.autoresizingMask = { afFlexibleWidth, afFlexibleMaxY }
    v.addSubview(label)
    v.addSubview(label2)
    v.addSubview(textField)

    let button = newButton(newRect(10, 40, 100, 22))
    button.title = "run"
    button.onAction do():
        label2.text = "exit code: " & (if textField.text.isNil: "nothing entered." else: intToStr(execShellCmd(textField.text), 2)) ## use nohup .. & ?
    v.addSubview(button)

    v.addSubview(textField)

registerSample(ControlsSampleView, "Controls")
proc startApplication() =

    var mainWindow : Window

    mainWindow = newWindow(newRect(40, 40, 400, 200))

    mainWindow.title = "bash-bar"

    var currentView = View.new(newRect(0, 0, mainWindow.bounds.width - 100, mainWindow.bounds.height))

    let splitView = newHorizontalLayout(mainWindow.bounds)
    splitView.resizingMask = "wh"
    splitView.userResizeable = true
    mainWindow.addSubview(splitView)
    let tableView = newTableView(newRect(0, 0, 120, mainWindow.bounds.height))
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
