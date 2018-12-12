#Region Assembler
;~ Description: Converts ASM commands to opcodes and updates global variables.
Func _($aASM)
   ;quick and dirty x86assembler unit:
   ;relative values stringregexp
   ;static values hardcoded
   Local $lBuffer
   Local $lOpCode = ''
   Local $lMnemonic = StringLeft($aASM, StringInStr($aASM, ' ') - 1)
   Select
	  Case $lMnemonic = "" ; variables and single word opcodes
		 Select
			Case StringRight($aASM, 1) = ':'
			   SetValue('Label_' & StringLeft($aASM, StringLen($aASM) - 1), $mASMSize)
			Case StringInStr($aASM, '/') > 0
			   SetValue('Label_' & StringLeft($aASM, StringInStr($aASM, '/') - 1), $mASMSize)
			   Local $lOffset = StringRight($aASM, StringLen($aASM) - StringInStr($aASM, '/'))
			   $mASMSize += $lOffset
			   $mASMCodeOffset += $lOffset
			Case $aASM = 'pushad' ; push all
			   $lOpCode = '60'
			Case $aASM = 'popad' ; pop all
			   $lOpCode = '61'
			Case $aASM = 'nop'
			   $lOpCode = '90'
			Case $aASM = 'retn'
			   $lOpCode = 'C3'
			Case $aASM = 'clc'
			   $lOpCode = 'F8'
		 EndSelect
	  Case $lMnemonic = "nop" ; nop
		 If StringLeft($aASM, 5) = 'nop x' Then
			$lBuffer = Int(Number(StringTrimLeft($aASM, 5)))
			$mASMSize += $lBuffer
			For $i = 1 To $lBuffer
			   $mASMString &= '90'
			Next
		 EndIf
	  Case StringLeft($lMnemonic, 2) = "lj" Or StringLeft($lMnemonic, 1) = "j" ; jump
		 Local $lStringLeft5 = StringLeft($aASM, 5)
		 Local $lStringLeft4 = StringLeft($aASM, 4)
		 Local $lStringLeft3 = StringLeft($aASM, 3)
		 Select
			Case $lStringLeft5 = 'ljmp '
			   $mASMSize += 5
			   $mASMString &= 'E9{' & StringRight($aASM, StringLen($aASM) - 5) & '}'
			Case $lStringLeft5 = 'ljne '
			   $mASMSize += 6
			   $mASMString &= '0F85{' & StringRight($aASM, StringLen($aASM) - 5) & '}'
			Case $lStringLeft4 = 'jmp ' And StringLen($aASM) > 7
			   $mASMSize += 2
			   $mASMString &= 'EB(' & StringRight($aASM, StringLen($aASM) - 4) & ')'
			Case $lStringLeft4 = 'jae '
			   $mASMSize += 2
			   $mASMString &= '73(' & StringRight($aASM, StringLen($aASM) - 4) & ')'
			Case $lStringLeft4 = 'jnz '
			   $mASMSize += 2
			   $mASMString &= '75(' & StringRight($aASM, StringLen($aASM) - 4) & ')'
			Case $lStringLeft4 = 'jbe '
			   $mASMSize += 2
			   $mASMString &= '76(' & StringRight($aASM, StringLen($aASM) - 4) & ')'
			Case $lStringLeft4 = 'jge '
			   $mASMSize += 2
			   $mASMString &= '7D(' & StringRight($aASM, StringLen($aASM) - 4) & ')'
			Case $lStringLeft4 = 'jle '
			   $mASMSize += 2
			   $mASMString &= '7E(' & StringRight($aASM, StringLen($aASM) - 4) & ')'
			Case $lStringLeft3 = 'ja '
			   $mASMSize += 2
			   $mASMString &= '77(' & StringRight($aASM, StringLen($aASM) - 3) & ')'
			Case $lStringLeft3 = 'jl '
			   $mASMSize += 2
			   $mASMString &= '7C(' & StringRight($aASM, StringLen($aASM) - 3) & ')'
			Case $lStringLeft3 = 'jz '
			   $mASMSize += 2
			   $mASMString &= '74(' & StringRight($aASM, StringLen($aASM) - 3) & ')'
			; hardcoded
			Case $aASM = 'jmp ebx'
			   $lOpCode = 'FFE3'
			Case Else
			   MsgBox(0, 'ASM', 'Could not assemble: ' & $aASM)
			   Exit
		 EndSelect
	  Case $lMnemonic = "mov" ; mov
		 Select
			; mov eax,dword[EnsureEnglish] 8BEC
			Case StringRegExp($aASM, 'mov eax,dword[[][a-z,A-Z]{4,}[]]')
			   $mASMSize += 5
			   $mASMString &= 'A1[' & StringMid($aASM, 15, StringLen($aASM) - 15) & ']'
			Case StringRegExp($aASM, 'mov ecx,dword[[][a-z,A-Z]{4,}[]]')
			   $mASMSize += 6
			   $mASMString &= '8B0D[' & StringMid($aASM, 15, StringLen($aASM) - 15) & ']'
			Case StringRegExp($aASM, 'mov edx,dword[[][a-z,A-Z]{4,}[]]')
			   $mASMSize += 6
			   $mASMString &= '8B15[' & StringMid($aASM, 15, StringLen($aASM) - 15) & ']'
			Case StringRegExp($aASM, 'mov ebx,dword[[][a-z,A-Z]{4,}[]]')
			   $mASMSize += 6
			   $mASMString &= '8B1D[' & StringMid($aASM, 15, StringLen($aASM) - 15) & ']'
			Case StringRegExp($aASM, 'mov esi,dword[[][a-z,A-Z]{4,}[]]')
			   $mASMSize += 6
			   $mASMString &= '8B35[' & StringMid($aASM, 15, StringLen($aASM) - 15) & ']'
			Case StringRegExp($aASM, 'mov edi,dword[[][a-z,A-Z]{4,}[]]')
			   $mASMSize += 6
			   $mASMString &= '8B3D[' & StringMid($aASM, 15, StringLen($aASM) - 15) & ']'
			; mov eax,TargetLogBase
			Case StringRegExp($aASM, 'mov eax,[a-z,A-Z]{4,}') And StringInStr($aASM, ',dword') = 0
			   $mASMSize += 5
			   $mASMString &= 'B8[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
			Case StringRegExp($aASM, 'mov edx,[a-z,A-Z]{4,}') And StringInStr($aASM, ',dword') = 0
			   $mASMSize += 5
			   $mASMString &= 'BA[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
			Case StringRegExp($aASM, 'mov ebx,[a-z,A-Z]{4,}') And StringInStr($aASM, ',dword') = 0
			   $mASMSize += 5
			   $mASMString &= 'BB[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
			Case StringRegExp($aASM, 'mov esi,[a-z,A-Z]{4,}') And StringInStr($aASM, ',dword') = 0
			   $mASMSize += 5
			   $mASMString &= 'BE[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
			Case StringRegExp($aASM, 'mov edi,[a-z,A-Z]{4,}') And StringInStr($aASM, ',dword') = 0
			   $mASMSize += 5
			   $mASMString &= 'BF[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
			; mov ecx,dword[ecx*4+TargetLogBase]
			Case StringRegExp($aASM, 'mov eax,dword[[]ecx[*]4[+][a-z,A-Z]{4,}[]]')
			   $mASMSize += 7
			   $mASMString &= '8B048D[' & StringMid($aASM, 21, StringLen($aASM) - 21) & ']'
			Case StringRegExp($aASM, 'mov ecx,dword[[]ecx[*]4[+][a-z,A-Z]{4,}[]]')
			   $mASMSize += 7
			   $mASMString &= '8B0C8D[' & StringMid($aASM, 21, StringLen($aASM) - 21) & ']'
			; mov eax,dword[ebp+8]
			Case StringRegExp($aASM, 'mov (eax|ecx|edx|ebx|esp|ebp|esi|edi),dword[[](ebp|esp)[+][-[:xdigit:]]{1,8}[]]')
			   Local $lASM = ''
			   Local $lBuffer = StringMid($aASM, 19, StringLen($aASM) - 19)
			   $lBuffer = ASMNumber($lBuffer, True)
			   If @extended Then
				  $mASMSize += 4
				  Local $lStart = 4
			   Else
				  $mASMSize += 7
				  Local $lStart = 8
			   EndIf
			   Switch StringMid($aASM, 5, 3)
				  Case 'eax'
					 $lASM &= Hex($lStart, 1) & '5'
				  Case 'ecx'
					 $lASM &= Hex($lStart, 1) & 'D'
				  Case 'edx'
					 $lASM &= Hex($lStart + 1, 1) & '5'
				  Case 'ebx'
					 $lASM &= Hex($lStart + 1, 1) & 'D'
				  Case 'esp'
					 $lASM &= Hex($lStart + 2, 1) & '5'
				  Case 'ebp'
					 $lASM &= Hex($lStart + 2, 1) & 'D'
				  Case 'esi'
					 $lASM &= Hex($lStart + 3, 1) & '5'
				  Case 'edi'
					 $lASM &= Hex($lStart + 3, 1) & 'D'
				  EndSwitch
			   If StringMid($aASM, 15, 3) = 'esp' Then
				  $mASMSize += 1
				  $lASM = Hex(Dec($lASM) - 1, 2) & '24'
			   EndIf
			   $mASMString &= '3E8B' & $lASM & $lBuffer
			; mov eax,dword[ecx+8]
			Case StringRegExp($aASM, 'mov (eax|ecx|edx|ebx|esp|ebp|esi|edi),dword[[](eax|ecx|edx|ebx|esi|edi)[+][-[:xdigit:]]{1,8}[]]')
			   Local $lASM = ''
			   Local $lBuffer = StringMid($aASM, 19, StringLen($aASM) - 19)
			   $lBuffer = ASMNumber($lBuffer, True)
			   If @extended Then
				  $mASMSize += 3
				  Local $lStart = 4
			   Else
				  $mASMSize += 6
				  Local $lStart = 8
			   EndIf
			   Switch StringMid($aASM, 5, 3)
				  Case 'eax'
					 $lASM &= Hex($lStart, 1) & '0'
				  Case 'ecx'
					 $lASM &= Hex($lStart, 1) & '8'
				  Case 'edx'
					 $lASM &= Hex($lStart + 1, 1) & '0'
				  Case 'ebx'
					 $lASM &= Hex($lStart + 1, 1) & '8'
				  Case 'esp'
					 $lASM &= Hex($lStart + 2, 1) & '0'
				  Case 'ebp'
					 $lASM &= Hex($lStart + 2, 1) & '8'
				  Case 'esi'
					 $lASM &= Hex($lStart + 3, 1) & '0'
				  Case 'edi'
					 $lASM &= Hex($lStart + 3, 1) & '8'
			   EndSwitch
			   $mASMString &= '8B' & ASMOperand(StringMid($aASM, 15, 3), $lASM) & $lBuffer
			; mov ebx,dword[edx]
			Case StringRegExp($aASM, 'mov (eax|ecx|edx|ebx|esp|ebp|esi|edi),dword[[](eax|ecx|edx|ebx|esp|ebp|esi|edi)[]]')
			   $mASMSize += 2
			   Switch StringMid($aASM, 5, 3)
				  Case 'eax'
					 $lBuffer = '00'
				  Case 'ecx'
					 $lBuffer = '08'
				  Case 'edx'
					 $lBuffer = '10'
				  Case 'ebx'
					 $lBuffer = '18'
				  Case 'esp'
					 $lBuffer = '20'
				  Case 'ebp'
					 $lBuffer = '28'
				  Case 'esi'
					 $lBuffer = '30'
				  Case 'edi'
					 $lBuffer = '38'
				  EndSwitch
			   $mASMSTring &= '8B' & ASMOperand(StringMid($aASM, 15, 3), $lBuffer, True)
			; mov eax,14
			Case StringRegExp($aASM, 'mov eax,[-[:xdigit:]]{1,8}\z')
			   $mASMSize += 5
			   $mASMString &= 'B8' & ASMNumber(StringMid($aASM, 9))
			Case StringRegExp($aASM, 'mov ebx,[-[:xdigit:]]{1,8}\z')
			   $mASMSize += 5
			   $mASMString &= 'BB' & ASMNumber(StringMid($aASM, 9))
			Case StringRegExp($aASM, 'mov ecx,[-[:xdigit:]]{1,8}\z')
			   $mASMSize += 5
			   $mASMString &= 'B9' & ASMNumber(StringMid($aASM, 9))
			Case StringRegExp($aASM, 'mov edx,[-[:xdigit:]]{1,8}\z')
			   $mASMSize += 5
			   $mASMString &= 'BA' & ASMNumber(StringMid($aASM, 9))
			; mov eax,ecx
			Case StringRegExp($aASM, 'mov (eax|ecx|edx|ebx|esp|ebp|esi|edi),(eax|ecx|edx|ebx|esp|ebp|esi|edi)')
			   $mASMSize += 2
			   Switch StringMid($aASM, 5, 3)
				  Case 'eax'
					 $lBuffer = 'C0'
				  Case 'ecx'
					 $lBuffer = 'C8'
				  Case 'edx'
					 $lBuffer = 'D0'
				  Case 'ebx'
					 $lBuffer = 'D8'
				  Case 'esp'
					 $lBuffer = 'E0'
				  Case 'ebp'
					 $lBuffer = 'E8'
				  Case 'esi'
					 $lBuffer = 'F0'
				  Case 'edi'
					 $lBuffer = 'F8'
				  EndSwitch
			   $mASMString &= '8B' & ASMOperand(StringMid($aASM, 9, 3), $lBuffer)
			; mov dword[TraderCostID],ecx
			Case StringRegExp($aASM, 'mov dword[[][a-z,A-Z]{4,}[]],ecx')
			   $mASMSize += 6
			   $mASMString &= '890D[' & StringMid($aASM, 11, StringLen($aASM) - 15) & ']'
			Case StringRegExp($aASM, 'mov dword[[][a-z,A-Z]{4,}[]],edx')
			   $mASMSize += 6
			   $mASMString &= '8915[' & StringMid($aASM, 11, StringLen($aASM) - 15) & ']'
			Case StringRegExp($aASM, 'mov dword[[][a-z,A-Z]{4,}[]],eax')
			   $mASMSize += 5
			   $mASMString &= 'A3[' & StringMid($aASM, 11, StringLen($aASM) - 15) & ']'
			; mov dword[NextStringType],2
			Case StringRegExp($aASM, 'mov dword\[[a-z,A-Z]{4,}\],[-[:xdigit:]]{1,8}\z')
			   $lBuffer = StringInStr($aASM, ",")
			   $mASMSize += 10
			   $mASMString &= 'C705[' & StringMid($aASM, 11, $lBuffer - 12) & ']' & ASMNumber(StringMid($aASM, $lBuffer + 1))
			; mov dword[edi],-1
			Case StringRegExp($aASM, 'mov dword[[](eax|ecx|edx|ebx|esp|ebp|esi|edi)[]],[-[:xdigit:]]{1,8}\z')
			   $mASMSize += 6
			   $mASMString &= 'C7' & ASMOperand(StringMid($aASM, 11, 3), '00', True) & _
							  ASMNumber(StringMid($aASM, 16, StringLen($aASM) - 15))
			; mov dword[eax+C],ecx
			Case StringRegExp($aASM, 'mov dword[[][abcdeipsx]{3}[-+[:xdigit:]]{2,9}[]],[abcdeipsx]{3}\z')
			   If StringMid($aASM, 14, 1) <> '+' Then
				  $lBuffer = BitNOT('0x' & StringMid($aASM, 15, StringInStr($aASM, ']') - 15)) + 1
			   Else
				  $lBuffer = StringMid($aASM, 15, StringInStr($aASM, ']') - 15)
			   EndIf
			   $lBuffer = ASMNumber($lBuffer, True)
			   If @extended Then
				  $mASMSize += 3
				  Local $lStart = 4
			   Else
				  $mASMSize += 6
				  Local $lStart = 8
			   EndIf
			   Local $lASM = ''
			   Switch StringMid($aASM, StringLen($aASM) - 2, 3)
				  Case 'eax'
					 $lASM = Hex($lStart, 1) & '0'
				  Case 'ecx'
					 $lASM = Hex($lStart, 1) & '8'
				  Case 'edx'
					 $lASM = Hex($lStart + 1, 1) & '0'
				  Case 'ebx'
					 $lASM = Hex($lStart + 1, 1) & '8'
				  Case 'esp'
					 $lASM = Hex($lStart + 2, 1) & '0'
				  Case 'ebp'
					 $lASM = Hex($lStart + 2, 1) & '8'
				  Case 'esi'
					 $lASM = Hex($lStart + 3, 1) & '0'
				  Case 'edi'
					 $lASM = Hex($lStart + 3, 1) & '8'
			   EndSwitch
			   $mASMString &= '89' & ASMOperand(StringMid($aASM, 11, 3), $lASM, True) &  $lBuffer
			; mov dword[eax],ecx
			Case StringRegExp($aASM, 'mov dword[[][a-z,A-Z]{4,}[]],esp');<======
				$mASMSize += 6
				$mASMString &= '8925[' & StringMid($aASM, 11, StringLen($aASM) - 15) & ']'
			Case StringRegExp($aASM, 'mov dword[[][abcdeipsx]{3}[]],[abcdeipsx]{3}\z')
				 $mASMSize += 2
			   $lBuffer = ''
			   Switch StringMid($aASM, StringLen($aASM) - 2, 3)
				  Case 'eax'
					 $lBuffer = '00'
				  Case 'ecx'
					 $lBuffer = '08'
				  Case 'edx'
					 $lBuffer = '10'
				  Case 'ebx'
					 $lBuffer = '18'
				  Case 'esp'
					 $lBuffer = '20'
				  Case 'ebp'
					 $lBuffer = '28'
				  Case 'esi'
					 $lBuffer = '30'
				  Case 'edi'
					 $lBuffer = '38'
			   EndSwitch
			   $mASMString &= '89' & ASMOperand(StringMid($aASM, 11, 3), $lBuffer, True)
			; hardcoded
			Case $aASM = 'mov al,byte[ecx+4f]'
			   $lOpCode = '8A414F'
			Case $aASM = 'mov al,byte[ecx+3f]'
			   $lOpCode = '8A413F'
			Case $aASM = 'mov al,byte[ebx]'
			   $lOpCode = '8A03'
			Case $aASM = 'mov al,byte[ecx]'
			   $lOpCode = '8A01'
			Case $aASM = 'mov ah,byte[edi]'
			   $lOpCode = '8A27'
			Case $aASM = 'mov dx,word[ecx]'
			   $lOpCode = '668B11'
			Case $aASM = 'mov dx,word[edx]'
			   $lOpCode = '668B12'
			Case $aASM = 'mov word[eax],dx'
			   $lOpCode = '668910'
			Case $aASM = 'mov ebp,esp'
			   $lOpCode = '8BEC';<---
			Case $aASM = 'mov edi,dword[ecx]';<-------
			   $lOpCode = '368B39'
			Case $aASM = 'mov dword[eax],edi';<------
			   $lOpCode = '368938'
			Case Else
			   MsgBox(0, 'ASM', 'Could not assemble: ' & $aASM)
			   Exit
		 EndSelect
	  Case $lMnemonic = "cmp" ; cmp
		 Select
			; cmp ebx,dword[MaxAgents]
			Case StringRegExp($aASM, 'cmp (eax|ecx|edx|ebx|esp|ebp|esi|edi),dword\[[a-z,A-Z]{4,}\]')
			   $lBuffer = ''
			   $mASMSize += 6
			   Switch StringMid($aASM, 5, 3)
				  Case 'eax'
					 $lBuffer = '05'
				  Case 'ecx'
					 $lBuffer = '0D'
				  Case 'edx'
					 $lBuffer = '15'
				  Case 'ebx'
					 $lBuffer = '1D'
				  Case 'esp'
					 $lBuffer = '25'
				  Case 'ebp'
					 $lBuffer = '2D'
				  Case 'esi'
					 $lBuffer = '35'
				  Case 'edi'
					 $lBuffer = '3D'
			   EndSwitch
			   $mASMString &= '3B' & $lBuffer & '[' & StringMid($aASM, 15, StringLen($aASM) - 15) & ']'
			; cmp edi,dword[esi]
			Case StringRegExp($aASM, 'cmp (eax|ecx|edx|ebx|esp|ebp|esi|edi),dword\[(eax|ecx|edx|ebx|esp|ebp|esi|edi)\]\z')
			   Local $lBuffer = StringMid($aASM, 15, 3)
			   If $lBuffer = 'ebp' Or $lBuffer = 'esp' Then
				  $mASMString &= '3E3B'
				  $mASMSize += 3
			   Else
				  $mASMString &= '3B'
				  $mASMSize += 2
			   EndIf
			   Switch StringMid($aASM, 5, 3)
				  Case 'eax'
					 $mASMString &= ASMOperand($lBuffer, '00', True, 64)
				  Case 'ecx'
					 $mASMString &= ASMOperand($lBuffer, '08', True, 64)
				  Case 'edx'
					 $mASMString &= ASMOperand($lBuffer, '10', True, 64)
				  Case 'ebx'
					 $mASMString &= ASMOperand($lBuffer, '18', True, 64)
				  Case 'esp'
					 $mASMString &= ASMOperand($lBuffer, '20', True, 64)
				  Case 'ebp'
					 $mASMString &= ASMOperand($lBuffer, '28', True, 64)
				  Case 'esi'
					 $mASMString &= ASMOperand($lBuffer, '30', True, 64)
				  Case 'edi'
					 $mASMString &= ASMOperand($lBuffer, '38', True, 64)
			   EndSwitch
			; cmp edi,dword[exi+4]
			Case StringRegExp($aASM, 'cmp (eax|ecx|edx|ebx|esp|ebp|esi|edi),dword\[(eax|ecx|edx|ebx|esp|ebp|esi|edi)[+-][[:xdigit:]]')
			   If StringMid($aASM, 18, 1) <> '+' Then
				  $lBuffer = BitNOT('0x' & StringMid($aASM, 19, StringLen($aASM) - 19)) + 1
			   Else
				  $lBuffer = StringMid($aASM, 19, StringLen($aASM) - 19)
			   EndIf
			   $lBuffer = ASMNumber($lBuffer, True)
			   If @extended Then
				  $mASMSize += 3
				  Local $lStart = 4
			   Else
				  $mASMSize += 6
				  Local $lStart = 8
			   EndIf
			   Switch StringMid($aASM, 15, 3)
				  Case 'ebp', 'esp'
					 Local $lASM = '3E3B'
					 $mASMSize += 1
				  Case Else
					 Local $lASM = '3B'
			   EndSwitch
			   Local $lASMOpcode = ''
			   Switch StringMid($aASM, 5, 3)
				  Case 'eax'
					 $lASMOpcode = Hex($lStart, 1) & '0'
				  Case 'ecx'
					 $lASMOpcode = Hex($lStart, 1) & '8'
				  Case 'edx'
					 $lASMOpcode = Hex($lStart + 1, 1) & '0'
				  Case 'ebx'
					 $lASMOpcode = Hex($lStart + 1, 1) & '8'
				  Case 'esp'
					 $lASMOpcode = Hex($lStart + 2, 1) & '0'
				  Case 'ebp'
					 $lASMOpcode = Hex($lStart + 2, 1) & '8'
				  Case 'esi'
					 $lASMOpcode = Hex($lStart + 3, 1) & '0'
				  Case 'edi'
					 $lASMOpcode = Hex($lStart + 3, 1) & '8'
			   EndSwitch
			   $mASMString &= $lASM & ASMOperand(StringMid($aASM, 15, 3), $lASMOpcode, True) &  $lBuffer
			; cmp dword[DisableRendering],1
			Case StringRegExp($aASM, 'cmp dword[[][a-z,A-Z]{4,}[]],[-[:xdigit:]]')
			   Local $lStart = StringInStr($aASM, ',')
			   If StringMid($aASM, $lStart + 1, 1) = '-' Then
				  $lBuffer = BitNOT('0x' & StringMid($aASM, $lStart + 2)) + 1
			   Else
				  $lBuffer = StringMid($aASM, $lStart + 1)
			   EndIf
			   $lBuffer = ASMNumber($lBuffer, True)
			   If @extended Then
				  $mASMSize += 7
				  $mASMString &= '833D[' & StringMid($aASM, 11, StringInStr($aASM, ",") - 12) & ']' & $lBuffer
			   Else
				  $mASMSize += 10
				  $mASMString &= '813D[' & StringMid($aASM, 11, StringInStr($aASM, ",") - 12) & ']' & $lBuffer
			   EndIf
			; cmp eax,TargetLogBase
			Case StringRegExp($aASM, 'cmp (eax|ecx|edx|ebx|esp|ebp|esi|edi),[a-z,A-Z]{4,}\z')
			   $lBuffer = ''
			   Switch StringMid($aASM, 5, 3)
				  Case 'eax'
					 $mASMSize += 5
					 $lBuffer = '3D'
				  Case 'ecx'
					 $mASMSize += 6
					 $lBuffer = '81F9'
				  Case 'edx'
					 $mASMSize += 6
					 $lBuffer = '81FA'
				  Case 'ebx'
					 $mASMSize += 6
					 $lBuffer = '81FB'
				  Case 'esp'
					 $mASMSize += 6
					 $lBuffer = '81FC'
				  Case 'ebp'
					 $mASMSize += 6
					 $lBuffer = '81FD'
				  Case 'esi'
					 $mASMSize += 6
					 $lBuffer = '81FE'
				  Case 'edi'
					 $mASMSize += 6
					 $lBuffer = '81FF'
			   EndSwitch
			   $mASMString &= $lBuffer & '[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
			; cmp ebx,14
		 Case StringRegExp($aASM, 'cmp (eax|ecx|edx|ebx|esp|ebp|esi|edi),[-[:xdigit:]]{1,}\z')
			   Local $lStart = StringInStr($aASM, ',')
			   If StringMid($aASM, $lStart + 1, 1) = '-' Then
				  $lBuffer = BitNOT('0x' & StringMid($aASM, $lStart + 2)) + 1
			   Else
				  $lBuffer = StringMid($aASM, $lStart + 1)
			   EndIf
			   $lBuffer = ASMNumber($lBuffer, True)
			   If @extended Then
				  $mASMSize += 3
				  $mASMString &= '83' & ASMOperand(StringMid($aASM, 5, 3), 'F8') & $lBuffer
			   Else
				  $mASMSize += 6
				  $mASMString &= '81' & ASMOperand(StringMid($aASM, 5, 3), 'F8') & $lBuffer
			   EndIf
			; cmp eax,ecx
			Case StringRegExp($aASM, 'cmp (eax|ecx|edx|ebx|esp|ebp|esi|edi),(eax|ecx|edx|ebx|esp|ebp|esi|edi)\z')
			   $lBuffer = ''
			   $mASMSize += 2
			   Switch StringMid($aASM, 9, 3)
				  Case 'eax'
					 $mASMString &= '39' & ASMOperand(StringMid($aASM, 5, 3), 'C0')
				  Case 'ecx'
					 $mASMString &= '39' & ASMOperand(StringMid($aASM, 5, 3), 'C8')
				  Case 'edx'
					 $mASMString &= '39' & ASMOperand(StringMid($aASM, 5, 3), 'D0')
				  Case 'ebx'
					 $mASMString &= '39' & ASMOperand(StringMid($aASM, 5, 3), 'D8')
				  Case 'esp'
					 $mASMString &= '39' & ASMOperand(StringMid($aASM, 5, 3), 'E0')
				  Case 'ebp'
					 $mASMString &= '39' & ASMOperand(StringMid($aASM, 5, 3), 'E8')
				  Case 'esi'
					 $mASMString &= '39' & ASMOperand(StringMid($aASM, 5, 3), 'F0')
				  Case 'edi'
					 $mASMString &= '39' & ASMOperand(StringMid($aASM, 5, 3), 'F8')
			   EndSwitch
			; hardcoded
			Case $aASM = 'cmp word[edx],0'
			   $lOpCode = '66833A00'
			Case $aASM = 'cmp al,ah'
			   $lOpCode = '3AC4'
			Case $aASM = 'cmp al,f'
			   $lOpCode = '3C0F'
			Case $aASM = 'cmp cl,byte[esi+1B1]'
			   $lOpCode = '3A8EB1010000'
			Case $aASM = 'cmp ecx,ebp';<----
			   $lOpCode = '39E9';<----
			Case Else
			   MsgBox(0, 'ASM', 'Could not assemble: ' & $aASM)
			   Exit
		 EndSelect
	  Case $lMnemonic = "lea" ; lea
		 Select
			; lea eax,dword[ecx*8+TargetLogBase]
			Case StringRegExp($aASM, 'lea eax,dword[[]ecx[*]8[+][a-z,A-Z]{4,}[]]')
			   $mASMSize += 7
			   $mASMString &= '8D04CD[' & StringMid($aASM, 21, StringLen($aASM) - 21) & ']'
			; lea eax,dword[ecx*4+TargetLogBase]
			Case StringRegExp($aASM, 'lea eax,dword[[]edx[*]4[+][a-z,A-Z]{4,}[]]')
			   $mASMSize += 7
			   $mASMString &= '8D0495[' & StringMid($aASM, 21, StringLen($aASM) - 21) & ']'
			; lea ebx,dword[eax*4+TargetLogBase]
			Case StringRegExp($aASM, 'lea ebx,dword[[]eax[*]4[+][a-z,A-Z]{4,}[]]')
			   $mASMSize += 7
			   $mASMString &= '8D1C85[' & StringMid($aASM, 21, StringLen($aASM) - 21) & ']'
			; hardcoded
			Case $aASM = 'lea eax,dword[eax+18]'
			   $lOpCode = '8D4018'
			Case $aASM = 'lea ecx,dword[eax+4]'
			   $lOpCode = '8D4804'
			Case $aASM = 'lea ecx,dword[eax+180]'
			   $lOpCode = '8D8880010000'
			Case $aASM = 'lea edx,dword[eax+4]'
			   $lOpCode = '8D5004'
			Case $aASM = 'lea edx,dword[eax+8]'
			   $lOpCode = '8D5008'
			Case $aASM = 'lea esi,dword[esi+ebx*4]'
			   $lOpCode = '8D349E'
			Case $aASM = 'lea edi,dword[edx+ebx]'
			   $lOpCode = '8D3C1A'
			Case $aASM = 'lea edi,dword[edx+8]'
			   $lOpCode = '8D7A08'
			Case Else
			   MsgBox(0, 'ASM', 'Could not assemble: ' & $aASM)
			   Exit
		 EndSelect
	  Case $lMnemonic = "add" ; add
		 Select
			; add eax, TargetLogBase
			Case StringRegExp($aASM, 'add eax,[a-z,A-Z]{4,}') And StringInStr($aASM, ',dword') = 0
			   $mASMSize += 5
			   $mASMString &= '05[' & StringRight($aASM, StringLen($aASM) - 8) & ']'
			; add eax,14
			Case StringRegExp($aASM, 'add eax,[-[:xdigit:]]{1,8}\z')
			   $lBuffer = ASMNumber(StringMid($aASM, 9), True)
			   If @extended Then
				  $mASMSize += 3
				  $mASMString &= '83C0' & $lBuffer
			   Else
				  $mASMSize += 5
				  $mASMString &= '05' & $lBuffer
			   EndIf
			Case StringRegExp($aASM, 'add ecx,[-[:xdigit:]]{1,8}\z')
			   $lBuffer = ASMNumber(StringMid($aASM, 9), True)
			   If @extended Then
				  $mASMSize += 3
				  $mASMString &= '83C1' & $lBuffer
			   Else
				  $mASMSize += 6
				  $mASMString &= '81C1' & $lBuffer
			   EndIf
			Case StringRegExp($aASM, 'add edx,[-[:xdigit:]]{1,8}\z')
			   $lBuffer = ASMNumber(StringMid($aASM, 9), True)
			   If @extended Then
				  $mASMSize += 3
				  $mASMString &= '83C2' & $lBuffer
			   Else
				  $mASMSize += 6
				  $mASMString &= '81C2' & $lBuffer
			   EndIf
			Case StringRegExp($aASM, 'add ebx,[-[:xdigit:]]{1,8}\z')
			   $lBuffer = ASMNumber(StringMid($aASM, 9), True)
			   If @extended Then
				  $mASMSize += 3
				  $mASMString &= '83C3' & $lBuffer
			   Else
				  $mASMSize += 6
				  $mASMString &= '81C3' & $lBuffer
			   EndIf
			Case StringRegExp($aASM, 'add edi,[-[:xdigit:]]{1,8}\z')
			   $lBuffer = ASMNumber(StringMid($aASM, 9), True)
			   If @extended Then
				  $mASMSize += 3
				  $mASMString &= '83C7' & $lBuffer
			   Else
				  $mASMSize += 6
				  $mASMString &= '81C7' & $lBuffer
			   EndIf
			Case Else
			   MsgBox(0, 'ASM', 'Could not assemble: ' & $aASM)
			   Exit
		 EndSelect
	  Case $lMnemonic = "fstp" ; fstp
		 ; fstp dword[EnsureEnglish]
		 If StringRegExp($aASM, 'fstp dword[[][a-z,A-Z]{4,}[]]') Then
			$mASMSize += 6
			$mASMString &= 'D91D[' & StringMid($aASM, 12, StringLen($aASM) - 12) & ']'
		 Else
			MsgBox(0, 'ASM', 'Could not assemble: ' & $aASM)
			Exit
		 EndIf
	  Case $lMnemonic = "push" ; push
		 Select
			; push dword[EnsureEnglish]
			Case StringRegExp($aASM, 'push dword[[][a-z,A-Z]{4,}[]]')
			   $mASMSize += 6
			   $mASMString &= 'FF35[' & StringMid($aASM, 12, StringLen($aASM) - 12) & ']'
			; push CallbackEvent
			Case StringRegExp($aASM, 'push [a-z,A-Z]{4,}\z')
			   $mASMSize += 5
			   $mASMString &= '68[' & StringMid($aASM, 6, StringLen($aASM) - 5) & ']'
			; push 14
			Case StringRegExp($aASM, 'push [-[:xdigit:]]{1,8}\z')
			   $lBuffer = ASMNumber(StringMid($aASM, 6), True)
			   If @extended Then
				  $mASMSize += 2
				  $mASMString &= '6A' & $lBuffer
			   Else
				  $mASMSize += 5
				  $mASMString &= '68' & $lBuffer
			   EndIf
			; hardcoded
			Case $aASM = 'push eax'
			   $lOpCode = '50'
			Case $aASM = 'push ecx'
			   $lOpCode = '51'
			Case $aASM = 'push edx'
			   $lOpCode = '52'
			Case $aASM = 'push ebx'
			   $lOpCode = '53'
			Case $aASM = 'push ebp'
			   $lOpCode = '55'
			Case $aASM = 'push esi'
			   $lOpCode = '56'
			Case $aASM = 'push edi'
			   $lOpCode = '57'
			Case $aASM = 'push dword[eax+4]'
			   $lOpCode = 'FF7004'
			Case $aASM = 'push dword[eax+8]'
				  $lOpCode = 'FF7008'
			Case $aASM = 'push dword[eax+c]'
			   $lOpCode = 'FF700C'
			Case Else
			   MsgBox(0, 'ASM', 'Could not assemble: ' & $aASM)
			   Exit
		 EndSelect
	  Case $lMnemonic = "pop" ; pop
		 ; hardcoded
		 Select
			Case $aASM = 'pop eax'
			   $lOpCode = '58'
			Case $aASM = 'pop ebx'
			   $lOpCode = '5B'
			Case $aASM = 'pop edx'
			   $lOpCode = '5A'
			Case $aASM = 'pop ecx'
			   $lOpCode = '59'
			Case $aASM = 'pop esi'
			   $lOpCode = '5E'
			Case $aASM = 'pop edi'
			   $lOpCode = '5F'
			Case $aASM = 'pop ebp'
			   $lOpCode = '5D'
			Case Else
			   MsgBox(0, 'ASM', 'Could not assemble: ' & $aASM)
			   Exit
		 EndSelect
	  Case $lMnemonic = "call" ; call
		 Select
			; call dword[EnsureEnglish]
			Case StringRegExp($aASM, 'call dword[[][a-z,A-Z]{4,}[]]')
			   $mASMSize += 6
			   $mASMString &= 'FF15[' & StringMid($aASM, 12, StringLen($aASM) - 12) & ']'
			; call ActionFunction
			Case StringLeft($aASM, 5) = 'call ' And StringLen($aASM) > 8
			   $mASMSize += 5
			   $mASMString &= 'E8{' & StringMid($aASM, 6, StringLen($aASM) - 5) & '}'
			Case Else
			   MsgBox(0, 'ASM', 'Could not assemble: ' & $aASM)
			   Exit
		 EndSelect
	  Case $lMnemonic = "test"
		 Switch $aAsm
			Case $aASM = 'test edi,edi'
			   $lOpCode = '85FF'
			Case $aASM = 'test eax,eax'
			   $lOpCode = '85C0'
			Case $aASM = 'test ecx,ecx'
			   $lOpCode = '85C9'
			Case $aASM = 'test ebx,ebx'
			   $lOpCode = '85DB'
			Case $aASM = 'test esi,esi'
			   $lOpCode = '85F6'
			Case $aASM = 'test dx,dx'
			   $lOpCode = '6685D2'
			Case $aASM = 'test al,al'
			   $lOpCode = '84C0'
			Case $aASM = 'test al,1'
			   $lOpCode = 'A801'
			Case Else
			   MsgBox(0, 'ASM', 'Could not assemble: ' & $aASM)
			   Exit
		 EndSwitch
	  Case $lMnemonic = "inc"
		 Select
			; inc dword[EnsureEnglish]
			Case StringRegExp($aASM, 'inc dword\[[a-zA-Z]{4,}\]')
			   $mASMSize += 6
			   $mASMString &= 'FF05[' & StringMid($aASM, 11, StringLen($aASM) - 11) & ']'
			Case $aASM = 'inc eax'
			   $lOpCode = '40'
			Case $aASM = 'inc ecx'
			   $lOpCode = '41'
			Case $aASM = 'inc edx'
			   $lOpCode = '42'
			Case $aASM = 'inc ebx'
			   $lOpCode = '43'
			Case Else
			   MsgBox(0, 'ASM', 'Could not assemble: ' & $aASM)
			   Exit
		 EndSelect
	  Case $lMnemonic = "dec"
		 Switch $aAsm
			Case $aASM = 'dec edx'
			   $lOpCode = '4A'
			Case Else
			   MsgBox(0, 'ASM', 'Could not assemble: ' & $aASM)
			   Exit
		 EndSwitch
	  Case $lMnemonic = "xor"
		 Switch $aAsm
			Case $aASM = 'xor eax,eax'
			   $lOpCode = '33C0'
			Case $aASM = 'xor ecx,ecx'
			   $lOpCode = '33C9'
			Case $aASM = 'xor edx,edx'
			   $lOpCode = '33D2'
			Case $aASM = 'xor ebx,ebx'
			   $lOpCode = '33DB'
			Case Else
			   MsgBox(0, 'ASM', 'Could not assemble: ' & $aASM)
			   Exit
		 EndSwitch
	  Case $lMnemonic = "sub"
		 Select
			Case StringRegExp($aASM, 'sub [abcdeipsx]{3},[-[:xdigit:]]{1,8}\z')
			   $lBuffer = ASMNumber(StringMid($aASM, 9, StringLen($aASM) - 8), True)
			   If @extended Then
				  $mASMSize += 3
			   Else
				  $mASMSize += 6
			   EndIf
			   $mASMString &= '83' & ASMOperand(StringMid($aASM, 5, 3), 'E8', False) & $lBuffer
			Case Else
			   MsgBox(0, 'ASM', 'Could not assemble: ' & $aASM)
			   Exit
		 EndSelect
	  Case $lMnemonic = "shl"
		 Switch $aAsm
			Case $aASM = 'shl eax,4'
			   $lOpCode = 'C1E004'
			Case $aASM = 'shl eax,6'
			   $lOpCode = 'C1E006'
			Case $aASM = 'shl eax,7'
			   $lOpCode = 'C1E007'
			Case $aASM = 'shl eax,8'
			   $lOpCode = 'C1E008'
			Case $aASM = 'shl eax,8'
			   $lOpCode = 'C1E008'
			Case $aASM = 'shl eax,9'
			   $lOpCode = 'C1E009'
			Case Else
			   MsgBox(0, 'ASM', 'Could not assemble: ' & $aASM)
			   Exit
		 EndSwitch
	  Case $lMnemonic = "retn"
		 If $aASM = 'retn 10' Then $lOpCode = 'C21000'
	  Case $aASM = 'repe movsb'
		 $lOpCode = 'F3A4'
	  Case Else
		 MsgBox(0, 'ASM', 'Could not assemble: ' & $aASM)
		 Exit
   EndSelect
   If $lOpCode <> '' Then
	  $mASMSize += 0.5 * StringLen($lOpCode)
	  $mASMString &= $lOpCode
   EndIf
EndFunc   ;==>_
#CS
Case 'push edi'
	$lOpCode = '57';<---
Case 'mov ebp,esp'
	$lOpCode = '8BEC';<---
Case 'mov edi,dword[ecx]';<-------
	$lOpCode = '368B39'
Case 'mov dword[eax],edi';<------
	$lOpCode = '368938'
Case 'cmp ecx,ebp'
	$lOpCode = '39E9';<----
#CE
;~ Description: Completes formatting of ASM code. Internal use only.
Func CompleteASMCode()
   Local $lInExpression = False
   Local $lExpression
   Local $lTempASM = $mASMString
   Local $lCurrentOffset = Dec(Hex($mMemory)) + $mASMCodeOffset
   Local $lToken
   For $i In $mLabelDict.Keys
	  If StringLeft($i, 6) = 'Label_' Then
		 $mLabelDict.Item($i) = $mMemory + $mLabelDict.Item($i)
		 $mLabelDict.Key($i) = StringTrimLeft($i, 6)
	  EndIf
   Next
   $mASMString = ''
   For $i = 1 To StringLen($lTempASM)
	  $lToken = StringMid($lTempASM, $i, 1)
	  Switch $lToken
		 Case '(', '[', '{'
			$lInExpression = True
		 Case ')'
			$mASMString &= Hex(GetLabelInfo($lExpression) - Int($lCurrentOffset) - 1, 2)
			$lCurrentOffset += 1
			$lInExpression = False
			$lExpression = ''
		 Case ']'
			$mASMString &= SwapEndian(Hex(GetLabelInfo($lExpression), 8))
			$lCurrentOffset += 4
			$lInExpression = False
			$lExpression = ''
		 Case '}'
			$mASMString &= SwapEndian(Hex(GetLabelInfo($lExpression) - Int($lCurrentOffset) - 4, 8))
			$lCurrentOffset += 4
			$lInExpression = False
			$lExpression = ''
		 Case Else
			If $lInExpression Then
			   $lExpression &= $lToken
			Else
			   $mASMString &= $lToken
			   $lCurrentOffset += 0.5
			EndIf
	  EndSwitch
   Next
EndFunc   ;==>CompleteASMCode

;~ Description: Returns GetValue($aLabel) and exits, if label cant be found.
Func GetLabelInfo($aLabel)
   Local $lValue = GetValue($aLabel)
   If $lValue = -1 Then Exit MsgBox(0, 'Label', 'Label: ' & $aLabel & ' not provided')
   Return $lValue
EndFunc   ;==>GetLabelInfo

;~ Description: Converts hexadecimal to ASM.
Func ASMNumber($aNumber, $aSmall = False)
   If $aNumber >= 0 Then
	  $aNumber = Dec($aNumber)
   EndIf
   If $aSmall And $aNumber <= 127 And $aNumber >= -128 Then
	  Return SetExtended(1, Hex($aNumber, 2))
   Else
	  Return SetExtended(0, SwapEndian(Hex($aNumber, 8)))
   EndIf
EndFunc   ;==>ASMNumber

;~ Descripion: Increases opcode-part according to opcode basis value.
Func ASMOperand($aSearchString, $aOpcodeString, $aESP = False, $aEBP = 0)
   Switch $aSearchString
	  Case 'eax'
		 Return $aOpcodeString
	  Case 'ecx'
		 Return Hex(Dec($aOpcodeString) + 1, 2)
	  Case 'edx'
		 Return Hex(Dec($aOpcodeString) + 2, 2)
	  Case 'ebx'
		 Return Hex(Dec($aOpcodeString) + 3, 2)
	  Case 'esp'
		 If $aESP Then
			$mASMSize += 1
			Return Hex(Dec($aOpcodeString) + 4, 2) & '24'
		 EndIf
		 Return Hex(Dec($aOpcodeString) + 4, 2)
	  Case 'ebp'
		 If $aEBP > 0 Then
			$mASMSize += 1
			Return Hex(Dec($aOpcodeString) + 5 + $aEBP, 2) & '00'
		 EndIf
		 Return Hex(Dec($aOpcodeString) + 5, 2)
	  Case 'esi'
		 Return Hex(Dec($aOpcodeString) + 6, 2)
	  Case 'edi'
		 Return Hex(Dec($aOpcodeString) + 7, 2)
   EndSwitch
EndFunc
#EndRegion Assembler