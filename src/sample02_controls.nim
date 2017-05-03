import nimx.view
import nimx.segmented_control
import nimx.color_picker
import nimx.button
import nimx.image
import nimx.image_view
import nimx.text_field
import nimx.types
import nimx.slider
import nimx.popup_button
import nimx.progress_indicator
import nimx.timer
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
    let textField = newTextField(newRect(120, 10, v.bounds.width - 130, 20))
    textField.autoresizingMask = { afFlexibleWidth, afFlexibleMaxY }
    label.text = "Text field:"
    v.addSubview(label)
    v.addSubview(textField)

    let tfLabel = newLabel(newRect(330, 150, 150, 20))
    tfLabel.text = "<-- Enter some text"
    let tf1 = newTextField(newRect(10, 150, 150, 20))
    tf1.onAction do():
        tfLabel.text = "textfield: " & (if tf1.text.isNil: "nil" else: tf1.text)

    let button = newButton(newRect(10, 40, 100, 22))
    button.title = "Button"
    button.onAction do():
        if textField.text.isNil: textField.text = ""
        textField.text = "entered: " & (if tf1.text.isNil: "nil" else: tf1.text)
    v.addSubview(button)

    v.addSubview(tfLabel)
    v.addSubview(tf1)

registerSample(ControlsSampleView, "Controls")
