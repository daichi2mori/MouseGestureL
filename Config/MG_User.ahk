﻿;===============================================================================
;
;		MouseGestureL.ahk 拡張スクリプト
;
;		・起動時の初期化処理や、ジェスチャー実行時に呼び出されるサブルーチン、
;		　関数などを定義できます。
;		・設定画面内の各種リストのサイズなども変更できます。
;		・内容を書き換えた場合はスクリプトをリロードしてください。
;
;===============================================================================

;----- ユーザー定義の初期化処理	------------------------------------------------
if (!MG_IsEdit) {
;...............................................................................
; MouseGestureL.ahk用








} else {
;...............................................................................
; MG_Edit.ahk用








}
;...............................................................................
; MouseGestureL.ahk、MG_Edit.ahk共通








;-------------------------------------------------------------------------------
Goto, MG_User_End

;----- ユーザー定義関数、サブルーチン	----------------------------------------










;...............................................................................
MG_PostInit() {
; MouseGestureL.ahkの初期化処理完了後に実行したい処理を以下に記述





}
;...............................................................................
ME_PostInit() {
; MG_Edit.ahkの初期化処理完了後に実行したい処理を以下に記述





}
;-------------------------------------------------------------------------------
MG_User_End: