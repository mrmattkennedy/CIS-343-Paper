#include <AutoItConstants.au3>
#include <GUIConstantsEx.au3>
#include <ColorConstants.au3>
#include <StaticConstants.au3>

Opt("GUIOnEventMode", True)

;Global constants used for GUI
Global $width = 500
Global $height = 400

Global $numButtons[10]
Global $buttonHeight = 60
Global $widthOffset = 300
Global $heightOffset = 30

;Create GUI window
Global $mainGUI = GUICreate("Calculator", $width, $height - 30)
	GUISetOnEvent($GUI_EVENT_CLOSE, "_Exit")
	GUISetFont(12)

;Create number buttons and set event functions
$numButtons[0] = GUICtrlCreateButton(0, $width - $widthOffset - ($buttonHeight * 2), $height - ($buttonHeight) - $heightOffset, 50, 50)
	GUICtrlSetOnEvent(-1, "AddToInput0")
$numButtons[1] = GUICtrlCreateButton(1, $width - $widthOffset - ($buttonHeight * 3), $height - ($buttonHeight * 2)- $heightOffset, 50, 50)
	GUICtrlSetOnEvent(-1, "AddToInput1")
$numButtons[2] = GUICtrlCreateButton(2, $width - $widthOffset - ($buttonHeight * 2), $height - ($buttonHeight * 2)- $heightOffset, 50, 50)
	GUICtrlSetOnEvent(-1, "AddToInput2")
$numButtons[3] = GUICtrlCreateButton(3, $width - $widthOffset - ($buttonHeight * 1), $height - ($buttonHeight * 2)- $heightOffset, 50, 50)
	GUICtrlSetOnEvent(-1, "AddToInput3")
$numButtons[4] = GUICtrlCreateButton(4, $width - $widthOffset - ($buttonHeight * 3), $height - ($buttonHeight * 3)- $heightOffset, 50, 50)
	GUICtrlSetOnEvent(-1, "AddToInput4")
$numButtons[5] = GUICtrlCreateButton(5, $width - $widthOffset - ($buttonHeight * 2), $height - ($buttonHeight * 3)- $heightOffset, 50, 50)
	GUICtrlSetOnEvent(-1, "AddToInput5")
$numButtons[6] = GUICtrlCreateButton(6, $width - $widthOffset - ($buttonHeight * 1), $height - ($buttonHeight * 3)- $heightOffset, 50, 50)
	GUICtrlSetOnEvent(-1, "AddToInput6")
$numButtons[7] = GUICtrlCreateButton(7, $width - $widthOffset - ($buttonHeight * 3), $height - ($buttonHeight * 4)- $heightOffset, 50, 50)
	GUICtrlSetOnEvent(-1, "AddToInput7")
$numButtons[8] = GUICtrlCreateButton(8, $width - $widthOffset - ($buttonHeight * 2), $height - ($buttonHeight * 4)- $heightOffset, 50, 50)
	GUICtrlSetOnEvent(-1, "AddToInput8")
$numButtons[9] = GUICtrlCreateButton(9, $width - $widthOffset - ($buttonHeight * 1), $height - ($buttonHeight * 4)- $heightOffset, 50, 50)
	GUICtrlSetOnEvent(-1, "AddToInput9")

;Create operator buttons and set event functions
Global $equalsBtn = GUICtrlCreateButton ("=", $width - $widthOffset, $height - ($buttonHeight * 1)- $heightOffset, 50, 50)
	GUICtrlSetOnEvent(-1, "DoMath")
Global $addBtn = GUICtrlCreateButton ("+", $width - $widthOffset, $height - ($buttonHeight * 2)- $heightOffset, 50, 50)
	GUICtrlSetOnEvent(-1, "AddToInputPlus")
Global $subBtn = GUICtrlCreateButton ("-", $width - $widthOffset, $height - ($buttonHeight * 3)- $heightOffset, 50, 50)
	GUICtrlSetOnEvent(-1, "AddToInputMinus")
Global $mulBtn = GUICtrlCreateButton ("x", $width - $widthOffset, $height - ($buttonHeight * 4)- $heightOffset, 50, 50)
	GUICtrlSetOnEvent(-1, "AddToInputMul")
Global $divBtn = GUICtrlCreateButton ("/", $width - $widthOffset, $height - ($buttonHeight * 5)- $heightOffset, 50, 50)
	GUICtrlSetOnEvent(-1, "AddToInputDiv")

;Create other buttons and set event functions
Global $decBtn = GUICtrlCreateButton (".", $width - $widthOffset - ($buttonHeight * 1), $height - ($buttonHeight * 1)- $heightOffset, 50, 50)
	GUICtrlSetOnEvent(-1, "AddToInputDecimal")
Global $signBtn = GUICtrlCreateButton ("+/-", $width - $widthOffset - ($buttonHeight * 3), $height - ($buttonHeight * 1)- $heightOffset, 50, 50)
	GUICtrlSetOnEvent(-1, "SwapSign")
Global $charBtn = GUICtrlCreateButton ("⌫", $width - $widthOffset - ($buttonHeight * 1), $height - ($buttonHeight * 5)- $heightOffset, 50, 50)
	GUICtrlSetOnEvent(-1, "RemoveCharacter")
Global $expBtn = GUICtrlCreateButton ("^", $width - $widthOffset - ($buttonHeight * 2), $height - ($buttonHeight * 5)- $heightOffset, 50, 50)
	GUICtrlSetOnEvent(-1, "AddToInputExp")
Global $clearBtn = GUICtrlCreateButton ("CE", $width - $widthOffset - ($buttonHeight * 3), $height - ($buttonHeight * 5)- $heightOffset, 50, 50)
	GUICtrlSetOnEvent(-1, "ClearInput")

;Labels to display data
Global $inputLabel = GUICtrlCreateLabel("", 20, 40- $heightOffset, 230, 50, $SS_RIGHT)
	GUICtrlSetBkColor(-1, $COLOR_WHITE)

;Log to show prior outputs.
Global $log = GUICtrlCreateLabel("", 270, 40- $heightOffset, 200, $height - 50)
	GUICtrlSetBkColor(-1, $COLOR_WHITE)
	GUICtrlSetFont(-1, 10)

;Used to do math
Global $currentOp = "None"
Global $firstOperator = "None"
GUISetState(@SW_SHOW)

;Program is event driven - do nothing until something happens.
While 1
	Sleep(20)
WEnd

Func AddToInput0()
	GUICtrlSetData($inputLabel, GUICtrlRead($inputLabel) & 0)
EndFunc

Func AddToInput1()
	GUICtrlSetData($inputLabel, GUICtrlRead($inputLabel) & 1)
EndFunc

Func AddToInput2()
	GUICtrlSetData($inputLabel, GUICtrlRead($inputLabel) & 2)
EndFunc

Func AddToInput3()
	GUICtrlSetData($inputLabel, GUICtrlRead($inputLabel) & 3)
EndFunc

Func AddToInput4()
	GUICtrlSetData($inputLabel, GUICtrlRead($inputLabel) & 4)
EndFunc

Func AddToInput5()
	GUICtrlSetData($inputLabel, GUICtrlRead($inputLabel) & 5)
EndFunc

Func AddToInput6()
	GUICtrlSetData($inputLabel, GUICtrlRead($inputLabel) & 6)
EndFunc

Func AddToInput7()
	GUICtrlSetData($inputLabel, GUICtrlRead($inputLabel) & 7)
EndFunc

Func AddToInput8()
	GUICtrlSetData($inputLabel, GUICtrlRead($inputLabel) & 8)
EndFunc

Func AddToInput9()
	GUICtrlSetData($inputLabel, GUICtrlRead($inputLabel) & 9)
EndFunc

Func AddToInputPlus()
	If StringRight(GUICtrlRead($inputLabel), 1) == "." Then Return
	$currentOp = "Add"
	$firstOperator = GUICtrlRead($inputLabel)
	GUICtrlSetData($inputLabel, "")
EndFunc

Func AddToInputMinus()
	If StringRight(GUICtrlRead($inputLabel), 1) == "." Then Return
	$firstOperator = GUICtrlRead($inputLabel)
	GUICtrlSetData($inputLabel, "")
	$currentOp = "Sub"
EndFunc

Func AddToInputMul()
	If StringRight(GUICtrlRead($inputLabel), 1) == "." Then Return
	$firstOperator = GUICtrlRead($inputLabel)
	GUICtrlSetData($inputLabel, "")
	$currentOp = "Mul"
EndFunc

Func AddToInputDiv()
	If StringRight(GUICtrlRead($inputLabel), 1) == "." Then Return
	$firstOperator = GUICtrlRead($inputLabel)
	GUICtrlSetData($inputLabel, "")
	$currentOp = "Div"
EndFunc

Func AddToInputExp()
	If StringRight(GUICtrlRead($inputLabel), 1) == "." Then Return
	$firstOperator = GUICtrlRead($inputLabel)
	GUICtrlSetData($inputLabel, "")
	$currentOp = "Exp"
EndFunc

Func AddToInputDecimal()
	GUICtrlSetData($inputLabel, GUICtrlRead($inputLabel) & ".")
EndFunc

Func SwapSign()
	$temp = GUICtrlRead($inputLabel)

	If (StringLen($temp)) == 0 Or $temp == 0 Then Return
	If StringLeft($temp, 1) == "-" Then
		GUICtrlSetData($inputLabel,StringMid(GUICtrlRead($inputLabel), 2))
	Else
		GUICtrlSetData($inputLabel, "-" & GUICtrlRead($inputLabel))
	EndIf

EndFunc

Func RemoveCharacter()
	GUICtrlSetData($inputLabel, StringMid(GUICtrlRead($inputLabel), 1, StringLen(GUICtrlRead($inputLabel)) - 1))
EndFunc

Func ClearInput()
	GUICtrlSetData($inputLabel, "")
	$firstOperator = "None"
	$currentOp = "None"
EndFunc

;Calculate result if input is good.
Func DoMath()
	If $firstOperator == "None" Or $currentOp == "None" Then Return
	$secondOperator = GUICtrlRead($inputLabel)
	If StringRight($secondOperator, 1) == "." Then Return
	If $secondOperator == 0 And $currentOp == "Div" Then Return

	;Input good, do math.
	$firstOpFloat = Number($firstOperator)
	$secondOpFloat = Number($secondOperator)
	$result = "None"
	$opSymbol = ""
	Switch $currentOp
		Case "Add"
			$result = $firstOpFloat + $secondOpFloat
			$opSymbol = "+"
		Case "Sub"
			$result = $firstOpFloat - $secondOpFloat
			$opSymbol = "-"
		Case "Mul"
			$result = $firstOpFloat * $secondOpFloat
			$opSymbol = "x"
		Case "Div"
			$result = $firstOpFloat / $secondOpFloat
			$opSymbol = "/"
		Case "Exp"
			$result = $firstOpFloat ^ $secondOpFloat
			$opSymbol = "^"
	EndSwitch

	;Result worked, set log.
	If $result <> "None" Then
		GUICtrlSetData($inputLabel, $result)
		GUICtrlSetData($log, $firstOperator & " " & $opSymbol & " " & $secondOperator & " = " & $result & @CRLF & @CRLF & GUICtrlRead($log))
		$secondOperator = "None"
		$currentOp = "None"
	EndIf

EndFunc

Func _Exit()
	Exit
EndFunc
