Class cstm.func.Customer Extends %RegisteredObject
{

// 復習4（復習2→ClassMethod）

ClassMethod saveData(code As %Integer, name As %String, kanaName As %String, birthDay As %Date, signUpDay As %Date, seibetsu As %Char, number As %String) As %Status
{

    /*
    エラーメッセージを表示する条件一覧
    <<顧客番号>>
    ・既に使われている
    ・未入力
    ・4桁以外
    <<氏名>>
    ・未入力
    <<カナ>>
    ・未入力
    <<生年月日>>
    ・未入力
    ・年が1840～9999（4桁）以外
    ・月が1～12以外
    ・日が1～31以外
    <<登録日>>
    ・未入力
    ・年が1840～9999（4桁）以外
    ・月が1～12以外
    ・日が1～31以外
    <<性別>>
    ・0，1，2，9以外
    <<電話番号>>
    ・最初の文字が０以外
    ・12桁以上
    */

    set result = $$$OK    
    set message = ""
    set data = ##class(cstm.data.Customer).%OpenId(code)
    
    //顧客番号が既にある
    if ( data '= "" ){
        //set message = "既に使用されている顧客番号です。"
    }
    //未入力

    if ( code = "" ){
        set message = "顧客番号が入力されていません。"
    }
    //４桁以外
    if ( ( code < 1000 ) ! ( 9999 < code ) ){
        set message = "顧客番号の桁数が誤っています。"
    }

    //氏名が未入力
    if ( name = "" ){
        set message = "氏名が未入力です。"
    }
    //カナが未入力
    if ( kanaName = "" ){
        set message = "カナ氏名が未入力です。"
    }

    //生年月日が未入力
    if ( birthDay = "" ){
        set message = "生年月日が入力されていません。"
    //yyyy/mm/dd形式以外  */が何個あるかは取得できない？
    }elseif ( $tr( birthDay, "0123456789", "" ) '= "//" ){
        set message = "生年月日の入力形式が誤っています。"
    }

    //登録日が未入力
    if ( signUpDay = "" ){
        set message = "登録日が入力されていません。"
    //yyyy/mm/dd形式以外
    }elseif ( $tr( signUpDay, "0123456789", "" ) '= "//" ){
        set message = "登録日の入力形式が誤っています。"
    }    

    //性別
    if ( seibetsu = "" ){ 
        set message = "性別が未入力です。"
    }elseif ( ( seibetsu '= 0 ) && (seibetsu '= 1) && (seibetsu '= 2) && (seibetsu '= 9) ){
        set message = "入力された数字に該当する性別がありません。"
    }
    
    //電話番号全角→半角
    if ( number '= "" ){
        set numberList = $lfs( $tr( number, "０１２３４５６７８９", "0123456789"), ",", 0 )

        //桁数
        set checkNum = 1
        set ngNum = ""
        for{
            set Number = $lg( numberList, checkNum ) quit:Number=""
            if ( ( 11 < $l( Number )) ! ($e( Number, 1, 1 ) '= 0 )){
                set ngNum = $s( ngNum="":checkNum, 1:ngNum_","_checkNum )
            }
            set checkNum = checkNum + 1
        }

    if ( ngNum ){
        set message = ngNum_"番目の電話番号に誤りがあります。"
    }

    }

    //データセット

    set data = ##class(cstm.data.Customer).%New()
    set data.code = code
    set data.name = name
    set data.kanaName = kanaName
    set data.birthDay = $s( birthDay'="":$zdh( $tr( birthDay, "/", "-" ), 3), 1:"")
    set data.signUpDay = $s( signUpDay'="":$zdh( $tr( signUpDay, "/", "-" ), 3 ), 1:"")
    set data.seibetsu = seibetsu
    
    /*電話番号*/

    if ( number '= "" ){
        for key = 1:1:checkNum-1 {
            do data.number.SetAt( $li( numberList, key ), key )
        }
    }

    quit:message'="" message

    set result = data.%Save()
    quit result
}

/*
//-----------------参考----------------------------
arrayの扱い

//<<配列>>
・追加＆変更
do data.arrayName.SetAt(value,key)
・削除
do data.arrayName.RemoveAt(key)　key番目の要素を削除。keyに数字を指定した場合、削除した数字の個所に隙間ができる。

//<<リスト>>
・追加
do.data.arrayName.Insert(value)　最後尾 / do.data.ArrayName.Insert(value,key) key（数字）番目
・変更
do data.arrayName.SetAt(value,key)　key番目の値を変更
・取得
do data.arrayName.GetAt(key)　key番目の値
do data.arrayName.GetPrevious(key)　key番目の直前の値
do data.arrayName.GetNext(key)　key番目の直後の値
do data.arrayName.Find(value,key)　key番目から開始して、次のvalueに等しい要素のキー
・削除
do data.arrayName.RemoveAt(key)　key番目の要素を削除。空いた個所は詰められる。
*/

/*
・入力された引数から検索条件を判定
    検索条件分岐一覧
    <<条件Null以外>>
    ・数値のみ→Id一致
    ・数値以外→カナ部分一致
    ・該当なし→全件
    <<条件Null>>
    ・→全件
・SQL文を作成
・
//---------------------------------------------------
*/

// SaveDataの引数確認個所にメソッドを使う

ClassMethod saveData2(code As %Integer, name As %String, kanaName As %String, birthDay As %Date, signUpDay As %Date, seibetsu As %Char, number As %String) As %Status
{

    /*
    エラーメッセージを表示するMethod

    <<顧客番号>>
    ・未入力
    ・既存
    ・桁数

    <<未入力>>
    ・氏名
    ・カナ

    <<日付>>
    ・登録日
    ・生年月日
    ・形式
    >・未入力
    >・年が1840～9999（4桁）以外
    >・月が1～12以外
    >・日が1～31以外

    <<電話番号>>
    ・最初の文字が０以外
    ・12桁以上

    */

    set result = $$$OK
    set check = "" 

    //顧客番号チェック
    set check = ..codeCheck( code )
    quit:check'="" check

    //未入力チェック（氏名・カナ）
    set check = ..nullCheck( name, kanaName )
    quit:check'="" check

    //日付チェック
    //生年月日
    if (..checkDate( birthDay, 1) = 0 ){
        quit "生年月日が正しくありません。"
    } 

    //登録日
    if (..checkDate( signUpDay, 1) = 0 ){
        quit "登録日が正しくありません。"
    } 

    //性別
    if ( ( seibetsu '= 0 ) && (seibetsu '= 1) && (seibetsu '= 2) && (seibetsu '= 9) ){
        quit "入力された数字に該当する性別がありません。"
    }
    
    //電話番号全角→半角
    if ( number '= "" ){

        set numberList = $lfs( $tr( number, "０１２３４５６７８９", "0123456789"), ",", 0 )

        //桁数
        set checkNum = 1
        set ngNum = ""
        for{
            set Number = $lg( numberList, checkNum ) quit:Number=""
            //数字以外が含まれている
            if ($tr( Number, "0123456789" , "" ) '= "" ){
                set ngNum = $s( ngNum="":checkNum, 1:ngNum_","_checkNum )
            //12桁以上　または　0以外からはじまる
            }elseif ( ( 11 < $l( Number )) ! ($e( Number, 1, 1 ) '= 0 )){
                set ngNum = $s( ngNum="":checkNum, 1:ngNum_","_checkNum )
            }
            set checkNum = checkNum + 1
        }

        if ( ngNum ){
            quit ngNum_"番目の電話番号に誤りがあります。"
        }

    }

    //データセット

    set data = ##class(cstm.data.Customer).%New()
    set data.code = code
    set data.name = name
    set data.kanaName = kanaName
    set data.birthDay = $s( birthDay'="":$zdh( $tr( birthDay, "/", "-" ), 3), 1:"")
    set data.signUpDay = $s( signUpDay'="":$zdh( $tr( signUpDay, "/", "-" ), 3 ), 1:"")
    set data.seibetsu = seibetsu
    
    /*電話番号*/

    if ( number '= "" ){
        for key = 1:1:checkNum-1 {
            do data.number.SetAt( $li( numberList, key ), key )
        }
    }

    set result = data.%Save()
    quit result
}

/*
//-----------------参考----------------------------
arrayの扱い

//<<配列>>
・追加＆変更
do data.arrayName.SetAt(value,key)
・削除
do data.arrayName.RemoveAt(key)　key番目の要素を削除。keyに数字を指定した場合、削除した数字の個所に隙間ができる。

//<<リスト>>
・追加
do.data.arrayName.Insert(value)　最後尾 / do.data.ArrayName.Insert(value,key) key（数字）番目
・変更
do data.arrayName.SetAt(value,key)　key番目の値を変更
・取得
do data.arrayName.GetAt(key)　key番目の値
do data.arrayName.GetPrevious(key)　key番目の直前の値
do data.arrayName.GetNext(key)　key番目の直後の値
do data.arrayName.Find(value,key)　key番目から開始して、次のvalueに等しい要素のキー
・削除
do data.arrayName.RemoveAt(key)　key番目の要素を削除。空いた個所は詰められる。
*/

/*
・入力された引数から検索条件を判定
    検索条件分岐一覧
    <<条件Null以外>>
    ・数値のみ→Id一致
    ・数値以外→カナ部分一致
    ・該当なし→全件
    <<条件Null>>
    ・→全件
・SQL文を作成
・
//-------------------------------------
*/

// 復習2のgetListをClassMethodへ

ClassMethod getList(require As %String) As %String
{
    set result = ""
    
    kill sql
    //検索条件の判定
    if ( require '= "" ){
            
        if ( $tr( require, "0123456789", "" ) = "" ){
            set mode = "num"
        }else{
            set mode = "kana"
        }

    }else{
        set mode = "full"
    }

    //write "TEST:mode:"_mode,!

    Try {
        //SQL作成
        set sql( $i( sql ) ) = "SELECT code, name, kanaName, seibetsu, birthDay, signUpDay "
        set sql( $i( sql ) ) = "FROM cstm_data.Customer "
        //write "TEST:1",!
        if ( mode = "num" ){
        //write "TEST:2",!
            set sql( $i( sql ) ) = "WHERE code = ? "
            set param( $i( param ) ) = require
        }elseif( mode = "kana" ){
            set sql( $i( sql ) ) = "WHERE kanaName like ? "
            set param( $i( param ) ) = "%"_require_"%"
        }
        //write "TEST:3",!

        set Stmt = ##class(%SQL.Statement).%New(1)
        //set Stmt.%SelectMode = 1

        //参照渡しの添え字付き配列を渡す 戻り値は１（成功：テーブルがネームスペース内に存在する）、0（失敗）
        set STATUS = Stmt.%Prepare(.sql)

        //エラーステータスでCatchへ
        $$$ThrowOnError(STATUS)

        if ( mode = "full" ){
            set rStatus = Stmt.%Execute()
        }else{
            //write "TEST:4",!
            set rStatus = Stmt.%Execute(param...)
            //write "TEST:4_2",!
        }

        //SQLCODE 0:成功,-1:エラー,100:データなし
        if (rStatus.%SQLCODE '= 0) && (rStatus.%SQLCODE '= 100) {
            //write "TEST:5",!
            do $SYSTEM.Status.DecomposeStatus(rStatus.%Message, .err)
            quit
        }

        while(rStatus.%Next()){

                set data = ##class(cstm.data.Customer).%OpenId( rStatus.code )
                set result = ..makeData( data )
                write:result'="" result,!,"---------------------",!
    
        }

        //write "TEST:8",!
    }
    Catch ex {
        write ex.Code,!
        write "ERROR:失敗しました。"
    }

    write:result="" "該当するデータがありません。"

    quit result
}

/*
//------------------参考-----------------------------
SQLステートメントの作成

%SelectMode:データ入力とデータ表示に使用するモードを指定
(　0
    0:%List型データ　内部ストレージ値は表示されない
    1:%List型データ　リスト要素をコンマで区切って表示
    2:%List型データ　リスト要素を$C(13,10)で区切って表示

%SchemaPath:未装飾のテーブル名のスキーマ名を指定するために使用する検索パスを指定
%Dialect:Transact-SQL(TSQL)Sybase言語あまたはMSSQL言語を指定。規定はIRIS（InterSystemSQL）

・set tStatment = ##class(%SQL.Statment).%New(selectmode,schemapath,dialect)  インスタンス化 ()内は空でもおｋ
・%Prepare() 成功または失敗のステータスを返す。
・%Execute()  %Prepare()または%PrepareClassQuery（）を使用して作成済みのSQLを実行。
（・%ExecDirect()　SQLを作成し、実行。）

//-----------------------------------------
*/

// 復習3をClassMethodへ

// 生年月日順で顧客情報を表示できるようにする

// 並べ替え  orderType = 1:code順, 2:birthDay順 nullなら1

ClassMethod getList2(orderType As %Integer) As %String
{
    set result = ""
    set:orderType="" orderType = 1

    kill sql

    //SQL作成

    /*  参考：テーブルが分かれているが、結合は不要
    set sql( $i( sql ) ) = "SELECT a.code, a.name, a.kanaName, a.seibetsu, a.birthDay, a.signUpDay, b.Customer, b.element_key AS ek, b.number "
    set sql( $i( sql ) ) = "FROM cstm_data.Customer AS a "
    set sql( $i( sql ) ) = "LEFT JOIN cstm_data.Customer_number AS b "
    set sql( $i( sql ) ) = "ON a.code = b.Customer"
    */

    set sql( $i( sql ) ) = "SELECT code, name, kanaName, seibetsu, birthDay, signUpDay "
    set sql( $i( sql ) ) = "FROM cstm_data.Customer "

    if ( orderType = 2 ){
        set sql( $i( sql ) ) = "ORDER BY birthDay"
    }

    set Stmt = ##class(%SQL.Statement).%New(1)
    //set Stmt.%SelectMode = 1　上記%New()内で渡すか、左記のように個別に設定。

    Try {

        //参照渡しの添え字付き配列を渡す 戻り値は１（成功：テーブルがネームスペース内に存在する）、0（失敗）
        set STATUS = Stmt.%Prepare(.sql)

        //エラーステータスでCatchへ
        $$$ThrowOnError(STATUS)

        set rStatus = Stmt.%Execute()

        //SQLCODE 0:成功,-1:エラー,100:データなし
        if ( (rStatus.%SQLCODE '= 0) & (rStatus.%SQLCODE '= 100) ) {
            do $SYSTEM.Status.DecomposeStatus(rStatus.%Message, .err)
            quit
        }

        while(rStatus.%Next()){

            set data = ##class(cstm.data.Customer).%OpenId( rStatus.code )
            set result = ..makeData( data )
            write:result'="" result,!,"---------------------",!

        }

    }
    Catch ex {
        write ex.Code,!
        write "ERROR:失敗しました。"
        quit
    }

    set:result="" result = "該当するデータがありません。"

    quit result
}

// 復習2>>集計

// require = 1:年代,  2:性別

ClassMethod getTotaling(require As %Integer) As %String
{

    set result = ""
    quit:require="" "条件番号を入力してください。"

    if ( require = 1 ){
        set target = "birthDay"
    }elseif ( require = 2 ){
        set target = "seibetsu"
    }

    set sql( $i( sql ) ) = "SELECT code, "_target_", name"
    set sql( $i( sql ) ) = "FROM cstm_data.Customer "

    set Stmt = ##class(%SQL.Statement).%New(1)

    try{

        set STATUS = Stmt.%Prepare( .sql )
        $$$ThrowOnError( STATUS )
        set rStatus = Stmt.%Execute()
        
        if ( ( rStatus.%SQLCODE '= 0 ) & ( rStatus.%SQLCODE '= 100 ) ){

            do $SYSTEM.Status.DecomposeStatus( rStatus.%Message, .err )
            quit 
        }

        set count = 0 

        while( rStatus.%Next() ){
            set data = ##class(cstm.data.Customer).%OpenId( rStatus.code )
            set res = ..makeTotaling( require, data )

    //w "::"_result
            set tkey = $p( res, ":", 1 )

            if ( $data( countArr( tkey )) '= 0 ){
                set countArr( tkey ) = countArr( tkey ) + 1
    //write "ok4"
            }else{
                set countArr( tkey ) = 1
    //write "ok3"
            }
    //write "ok5"
            set targetArr( tkey, countArr( tkey ) ) = $p( res, ":", 2 )_"："_$p( res, ":", 3 )

            set count = count + 1

        }

        //表示
        set key = ""
        for{
            set key = $order( countArr( key ))  quit:key=""
            set result = result_key_$c(13,10)
            set key2 = ""
            for{
                set key2 = $order( targetArr( key ,key2) ) quit:key2=""
                set result = result_targetArr( key ,key2)_$c(13,10)
                set total = key2
            }
            set result = result_"合計："_total_"人"_$c(13,10)
            set result = result_"-----------------------------"_$c(13,10)
        }

    } catch ex{
        write ex.Code,!
        write "ERROR:失敗しました。"
        quit
    }

    write:result'="" result
    return result
}

// 顧客データを作成する

ClassMethod makeData(data As cstm.data.Customer) As %String
{

    set returnData = ""
    set code = data.code
    set name = data.name
    set kana = data.kanaName
    set seibetsu = $case( data.seibetsu, 0:"不明", 1:"男性", 2:"女性", 9:"その他" )
    set birthDay = $zd( data.birthDay, 3 )
    set signUpDay = $zd( data.signUpDay, 3 )

    set ek = "", number =""
    for{
        set value = data.number.GetNext(.ek) quit:ek=""
        set number = number_$s(number="":value_$c(13,10),1: $c(9)_":"_value_$c(13,10))
    }

    set titleArr = $lb("顧客番号", "氏名", "カナ", "性別", "生年月日", "登録日","電話番号")
    set itemArr = $lb(code,name,kana,seibetsu,birthDay,signUpDay,number)

    set key = 1, title = ""

    for{
        set title = $lg( titleArr,key ) quit:title=""
        set returnData = returnData_title_":"_$li( itemArr, key )_$c(13,10)
        set key = key + 1
    }

    return returnData
}

// 顧客の電話番号データを作成する

ClassMethod makeNumberData(number As %String, ek As %Integer) As %String
{

    set returData = ""
    if ( ek=1 ){
        set returData = "電話番号："_number_$c(13,10)
    }else{
        set returData = $c(9)_number_$c(13,10)
    }
}

// 条件（require）別顧客データの集計を行う

// 引数に集計条件（require）とデータを渡す

// require=1:年代別集計データの作成,require=2:性別別集計データの作成

ClassMethod makeTotaling(require As %Integer, data As cstm.data.Customer) As %String
{

    set returData = ""
    set code = data.code
    set name = data.name

    //年代
    if ( require = 1 ){
        set targetName = "birthDay"
        set now = $p( $zd( $h, 3 ), "-", 1 )
        set umaredoshi = $p( $zd( data.birthDay, 3 ), "-", 1 )
        set targetNum = $e( ( now - umaredoshi ), 1, 1 ) * 10
        set target = targetNum_"代"

    //性別
    }elseif ( require = 2 ){
        set targetName = "seibetsu"
        set targetNum = data.seibetsu
        set target = $case(targetNum,0:"不明",1:"男性",2:"女性",9:"その他")
    }

    set returnData = target_":"_code_":"_name
    return returnData
}

// 日付形式を確認する

// 引数に日付（date）,null可否(nulltype)を渡す

// nulltype = 1 :null不可, nulltype = 2: null可

// 戻り値に形式の正誤を返す

// チェック  正:1, 誤:0

/*　確認事項
・年>>４桁、数値、18401231～99991231
・月>>２桁、数値、1～12
・日>>２桁、数値、1～31（２月は２９日、４/６/９月は３０日まで）
*/
ClassMethod checkDate(date As %Date, nulltype As %Integer) As %Integer
{

    //dateがnull
    if ( date = "" ){
        if ( nulltype = 2 ){
            return 1
        }else{
            return 0
        }
    }

    //dateあり
    //Year
    set Year = $p( date, "/", 1 )
    if ( Year < 1840 ! 9999 < Year ){
        return 0
    }

    //Month
    set Month = $p( date, "/", 2 )
    if ( Month < 1 ! 12 <  Month ){
        return 0
    }
    set Month = $e( 100 + Month, 2, 3 )

    //Day
    set Day = $p( date, "/", 3 )
    if ( Day < 1 ! 31 < Day ){
        return 0
    }

    if ( 30 <= Day ){
        if ( Month = 2 ){
            return 0
        }elseif ( Month = 4 ! Month = 6 ! Month = 9 ){
            if ( Day = 31 ){
                return 0
            }
        }
    }
    set Day = $e( 100 + Month, 2, 3 )

    //18400101~18411230不可
    if ( Year_Month_Day < 18401231 ){
        return 0
    }

    //成功
    return 1
}

// 顧客番号が使用可能かどうか確認する

// 引数に顧客番号（code）を渡す

/*　確認項目
・既存
・未入力
・４桁以外
・数値以外
*/

// 戻り値にエラー文（message）を返す

// message="":エラーなし

ClassMethod codeCheck(code As %Integer) As %String
{
    set message = ""

    set data = ##class(cstm.data.Customer).%OpenId(code)

    //既にある
    if ( data '= "" ){
        set message = "既に使用されている顧客番号です。"
    }

    //未入力
    if ( code = "" ){
        set message = "顧客番号が入力されていません。"
    }

    //数値以外が含まれている
    if ( ( $tr( code, "0123456789", "" ) ) '= "" ){
        set message = "顧客番号に数値以外が含まれています。"
    } 

    //４桁以外
    if ( ( code < 1000 ) ! ( 9999 < code ) ){
        set message = "顧客番号の桁数が誤っています。"
    }

    return message
}

// 入力必須の項目について入力値を確認する

// 引数に入力必須項目を渡す

// 戻り値にエラー文（message）を返す

// message="":エラーなし

ClassMethod nullCheck(name As %String, kanaName) As %String
{
    set message = ""


    //氏名が未入力
    if ( name = "" ){
        set message = "氏名が未入力です。"
    }

    //カナが未入力
    if ( kanaName = "" ){
        set message = message_",カナ氏名が未入力です。"
    }

    return message
}

/*--------------参考-----*/

// エラー文を作成

// 引数にエラー番号（eNumber）を渡す

// 戻り値にエラー文（message）を返す

// 配列にない番号を渡した場合は”その他のエラー”

ClassMethod returnError(eNumber As %Integer) As %String
{
    set message = ""

    //1~10 code
    set eArray(1) = "既に使用されている顧客番号です"
    set eArray(2) = "顧客番号が入力されていません。"
    set eArray(3) = "顧客番号の桁数が誤っています。"

    //11~20 name/kanaName
    set eArray(11) = "氏名が未入力です。"
    set eArray(12) = "カナ氏名が未入力です。"

    //21~30 birthDay
    set eArray(21) = "生年月日が未入力です。"
    set eArray(22) = "生年月日の年が正しくありません。"
    set eArray(23) = "生年月日の月が正しくありません。"
    set eArray(24) = "生年月日の日が正しくありません。"

    //31~40 signUpDay
    set eArray(31) = "生年月日が未入力です。"
    set eArray(32) = "生年月日の年が正しくありません。"
    set eArray(33) = "生年月日の月が正しくありません。"
    set eArray(34) = "生年月日の日が正しくありません。"
    //41~50 seibetsu
    set eArray(41) = "性別が未入力です。"
    set eArray(42) = "入力された数字に該当する性別がありません。"

    //51~60 number
    set eArray(51) = "電話番号が未入力です。"
    set eArray(52) = "電話番号の桁数が正しくありません。"
    set eArray(53) = "電話番号に数字以外が含まれています。"

    if ( $data( eArray( eNumber ) ) '= 0 ){
            set message = eArray( eNumber )
    }else{
        set message = "その他のエラー"
    }

    return message
}

}
