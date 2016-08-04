
Option Explicit

Private Sub cmdCancel_Click()
    Unload Me
End Sub

Public Function getTableName(strAColVal As String)
 Dim a As Variant
 Dim b As Variant
 a = Split(strAColVal, "=")
 b = UBound(a)
End Function

Private Sub cmdConfirm_Click()

On Error GoTo ErrLine


    Dim lngStartNum As Long
    Dim lngEndNum   As Long
    
    Dim strResult1  As String
    Dim strResult2  As String
    Dim strResult3  As String
    Dim strResult4  As String
    Dim strResult5  As String
    
    Dim strResult   As String
    
    Dim intIdx      As Integer
    Dim lngLen      As Long
    Dim lngFreeFile As Long
    
    Dim strfPath    As String
    
    Dim ConstTableNameCol As String
    ConstTableNameCol = "A"
    Dim strTableName As String
    
    

    
    'lngStartNum
    If Trim(txtStartNum.Text) <> "" Then
        lngStartNum = CLng(Trim(txtStartNum.Text))
    Else
        MsgBox "StartNum"
        Exit Sub
    End If
    
    'lngEndNum
    If Trim(txtEndNum.Text) <> "" Then
        lngEndNum = Trim(txtEndNum.Text)
    Else
        MsgBox "EndNum"
        Exit Sub
    End If
    
    strResult1 = "/*  " + "  */"
    strResult2 = "CREATE TABLE " + " ("
    
    lngFreeFile = FreeFile
    
    strResult = ""
    strResult = strResult + strResult1 + vbCrLf
    strResult = strResult + strResult2 + vbCrLf
    
    Dim strTableName
    Dim strTableColumn
    
    For intIdx = lngStartNum To lngEndNum
    
        If isEmptyRow(intIdx) Then
            strTableName = ""
            strTableColumn = ""
        Else
            If strTableName <> "" Then
                strResult = strResult + strTableColumn + getTableColumnValue(intIdx)
            Else
                strTableName = getTableName(intIdx)
                If strTableName <> "" Then
                    strTableColumn = getTableColumn(intIdx + 1)
                End If
            End If
        
        End If

    Next
    
   
ErrLine:
    
    MsgBox Err.Description, vbOKOnly + vbExclamation

    
End Sub

Public Function seqCodeEndColumn(intRowIdx As Integer)
    Dim colsCount As Long
    colsCount = ActiveSheet.Rows(3).Find("", , , xlWhole).Column
    seqCodeEndColumn = colsCount + 1
End Function

Public Function isEmptyRow(intRowIdx As Integer)
    Dim strTableName As String
    
    isEmptyRow = True
    strTableName = CStr(ActiveSheet.Range(ConstTableNameCol & intRowIdx).Value)
    If strTableName <> "" Then
        isEmptyRow = False
    End If

End Function

Public Function getTableName(intRowIdx As Integer)
    Dim pos As Integer
    Dim strTableName As String
    
    strTableName = CStr(ActiveSheet.Range(ConstTableNameCol & intRowIdx).Value)
    If strTableName <> "" Then
        pos = InStr(1, strTableName, "table=", 1)
        If pos > 0 Then
            strTableName = Mid(strTableName, pos + 6)
        Else
            strTableName = ""
        End If
    End If
    getTableName = strTableName
End Function

Public Function getTableColumn(intRowIdx As Integer)
    Dim lpb As Long
    Dim colsCount As Long
    Dim strResult As String
        
    colsCount = ActiveSheet.Rows(intRowIdx).Find("", LookIn:=xlValues).Column + 1
    
    strResult = "("
    For lpb = 1 To colsCount
      strResult = strResult + "," + ActiveSheet.Cells(1, lpb).Value
    Next lpb
    
    getTableColumn = strResult + ")"

End Function

Public Function getTableColumnValue(intRowIdx As Integer)
    Dim lpb As Long
    Dim colsCount As Long
    Dim strResult As String
        
    colsCount = ActiveSheet.Rows(intRowIdx).Find("", LookIn:=xlValues).Column + 1
    
    strResult = "("
    For lpb = 1 To colsCount
      strResult = strResult + "," + ActiveSheet.Cells(1, lpb).Value
    Next lpb
    
    getTableColumn = strResult + ")"

End Function

Private Sub UserForm_Initialize()
    
    Dim lngSum  As Long
    
    lngSum = 5
    
    While ActiveSheet.Range("B" & lngSum).Value <> "" And ActiveSheet.Range("C" & lngSum).Value <> ""
        lngSum = lngSum + 1
    Wend
    
    If lngSum = 5 Then
        txtEndNum.Text = lngSum
    Else
        txtEndNum.Text = lngSum - 1
    End If



End Sub

Private Function callSaveDlg(strDefPath As String) As String

    Dim varOpenFile     As Variant
    
    callSaveDlg = ""
    
    varOpenFile = Application.GetSaveAsFilename(strDefPath, "僥乕僽儖 僼傽僀儖 (*.tbl),*.tbl,偡傋偰 僼傽僀儖 (*.*),*.*")
    
    If varOpenFile <> False Then
        callSaveDlg = varOpenFile
    End If
    
End Function

----basepublic
Option Explicit


'-----  ------------------------------------------------------------
Public Const GD_NAME = "SugetsuTest"
Public Const GD_VERSION = "_1.0"
Public Const GD_THIS_WORKBOOK_NAME = GD_NAME + GD_VERSION + ".xla"


Public Sub createTableSQL()

    frmGetTableSQL.Show
End Sub

Public Sub delMenu()

    On Error Resume Next
    
    If MsgBox(GD_NAME & "delete menu", vbYesNoCancel + vbQuestion) <> vbYes Then
        Exit Sub
    End If
    
    Dim cmdBarTarget    As CommandBar
    
    Set cmdBarTarget = Application.CommandBars("Worksheet Menu Bar")
    cmdBarTarget.Reset
    ThisWorkbook.Close
    
End Sub


---worksheet--
Option Explicit

Private Sub Workbook_Open()
'********************************************************************************
'           when excel open,add menu to menuBar
'********************************************************************************
    Dim cmdBarTarget    As CommandBar
    Dim objNewMenu      As Object
    Dim objNewItem      As Object
    Dim varLoopVar      As Variant
    Dim intStat         As Integer
    Dim objNewSubItem   As Object

    On Error Resume Next
    
    '/* excel menu bar */
    Set cmdBarTarget = Application.CommandBars("Worksheet Menu Bar")
    cmdBarTarget.Visible = True
    
    '/* if menu is added */
    intStat = 0
    With cmdBarTarget
        For Each varLoopVar In .Controls
            If (varLoopVar.Caption = GD_NAME) Then
                intStat = 1
                Exit For
            End If
        Next varLoopVar
    End With
    '/* not add */
    If (intStat = 0) Then
        Set objNewMenu = cmdBarTarget.Controls.Add(Type:=msoControlPopup, ID:=1, Temporary:=True)
        objNewMenu.Caption = GD_NAME
        intStat = 1
    '/* the menu added */
    Else
        Set objNewMenu = cmdBarTarget.Controls.Item(GD_NAME)
        With objNewMenu
            For Each varLoopVar In .Controls
                If (varLoopVar.Caption = "insert sql") Then
                    intStat = 2
                    Exit For
                End If
            Next varLoopVar
            intStat = 1
        End With
    End If

    '/*  */
    If (intStat = 1) Then
        
        Set objNewItem = objNewMenu.Controls.Add(Type:=msoControlButton, ID:=1, Temporary:=True)
        objNewItem.Caption = "inset sql"
        objNewItem.OnAction = GD_THIS_WORKBOOK_NAME & "!createTableSQL"
        

    
        Set objNewItem = objNewMenu.Controls.Add(Type:=msoControlButton, ID:=1, Temporary:=True)
        objNewItem.Caption = "delete menu"
        objNewItem.BeginGroup = True
        objNewItem.OnAction = GD_THIS_WORKBOOK_NAME & "!delMenu"
    End If

End Sub


