Class user.func.User Extends %RegisteredObject
{

// saveData(社員コード,漢字氏名,カナ氏名,生年月日,性別) 引数に設定された社員情報を登録する。※戻り値に成功可否を設定する。

ClassMethod saveData(code As %Integer, name As %String, kanaName As %String, birthDay As %Date, seibetsu As %Char) As %Status
{
    set result = ""

    /*
    既存データに同一のユーザーIDがあれば、その内容を置き換える
    */

    // 既にあるかどうか
    set data = ##class(user.data.User).%OpenId( code )
    if ('$IsObject(data)) {
        // 新しいデータの作成
        set data = ##class(user.data.User).%New()
        set data.code = code
    }

    set data.name = name
    set data.kanaName = kanaName
    set data.birthDay = $zdh( birthDay, 3 )
    set data.seibetsu = seibetsu

    /*
    do data.phone.Clear()
    do data.phone.add("")
    do data.phone.add("")
    */

    set result = data.%Save()






    /*
    set data = ##class(user.data.User).%OpenId( code )

    //社員コードに重複があれば元データを削除
    if ( data '= "" ){
        set id = data.%Id()
        set data = data.%DeleteId( id )
    }
    
    set data = ##class(user.data.User).%New()
    set data.code = code
    set data.name = name
    set data.kanaName = kanaName
    set data.birthDay = $zdh( birthDay, 3 )
    set data.seibetsu = seibetsu

    set result = data.%Save()
    */

    quit result
}

// getData（社員コード） 引数（社員コード）の社員氏名を戻り値に設定する。

ClassMethod getData(code As %Integer) As %String
{
    //set result = ""
    set data = ##class(user.data.User).%OpenId( code )

    quit:'$IsObject( data ) "データがありません。"

    //set result = data.name
    //quit result
    quit data.name
}

// getList（検索条件）引数にmodeと条件を渡し、合致する全社員の全情報を書き出す。（社員コード：氏名：カナ：生年月日（YYYY-MM-DD）：性別）

ClassMethod getList(mode As %Integer, require As %String) As %String
{

    set id = "", result = ""

    // SQL
    set sql($i(sql)) = "SELECT code, name, kanaName, seibetsu, birthDay "
    set sql($i(sql)) = "FROM user_data.""User"" "
    if (mode = 1) {
        set sql($i(sql)) = "WHERE seibetsu = ?"
        set param($i(param)) = require
    } elseif (mode = 2) ! (mode = 3) {
        set sql($i(sql)) = "WHERE kanaName like = ?"
        set param($i(param)) = $select(mode=3:"%"_require, mode=2:"%"_require_"%")
    }

    set rstm = ##class(%SQL.Statement).%New()
    set rstm.%SelectMode = 1
    $$$THROWONERROR(r, rstm.%Prepare(.sql))
    if (mode = 1) ! (mode = 2) ! (mode = 3) {
        set res = rstm.%Execute(param...)
    } else {
        set res = rstm.%Execute()
    }

    if (res.%SQLCODE '= 0) && (res.%SQLCODE '= 100) {
        d $SYSTEM.Status.DecomposeStatus(res.%Message, .err)
        quit ""
    }

    while(res.%Next(.ec)) {
        set data = ##class(user.data.User).%OpenId( res.code )
        w res.name
        set result = ..makeData( data )
        write result,!
    }
    if ($$$ISERR(ec)) {
        $$$ThrowOnError(ec)
    }




    /*
    for{
        //$order？
        //set id = id + 1
        //対応するグローバルのIdKeyを回してid（code）を探す
        set id = $order( ^user.data.UserD( id ) ) quit:id=""
        set result = ""
        set data = ##class(user.data.User).%OpenId( id )
        //objectでなければquit　なお$orderで検索しているため、データがNULLになることはない
        quit:'$IsObject( data )
        //set code = data.%Id()

        //性別一致
        if (  mode = 1 ){

            if ( data.seibetsu = require ){

                //set result = ##class(user.func.User).makeData( code )
                //同クラス内のメソッドは..で呼べる
                set result = ..makeData( data )
            }
            
        //カナ一致
        } elseif ( ( mode = 2 ) ! ( mode = 3 )){

            //部分一致
            if ( ( mode = 2 ) & ( data.kanaName [ require ) ){

                //set result = ##class(user.func.User).makeData( code )
                set result = ..makeData( data )

            //前方一致
            }elseif( ( mode = 3 ) & ( $e( ( data.kanaName ), 1, $l( require ) ) = require ) ){

                //set result = ##class(user.func.User).makeData( code )
                set result = ..makeData( data )
            }
        
        //条件入力なし
        } else {

            //set result = ##class(user.func.User).makeData( code )
            set result = ..makeData( data )
        }

        write:result'="" result,!

    }
    */

    quit result
}

// 社員情報作成

// ClassMethod makeData(code As %Integer) As %String

ClassMethod makeData(data As user.data.User) As %String
{

    //set data = ##class(user.data.User).%OpenId( code )
    set returnData = ""
    set code = data.code
    set name = data.name
    set kana = data.kanaName
    set birthDay = $zd( data.birthDay, 3 )
    set seibetsu = $case( data.seibetsu, 0:"不明", 1:"男性", 3:"女性", 9:"その他")
    set returnData = code_":"_name_":"_kana_":"_birthDay_":"_seibetsu
    return returnData
}

/*---------------------参考 ----------------------*/

// makeDataがobjectを受け取ってデータを作成するメソッドとして、インスタンス化とmakeDataを呼ぶメソッドをmakeDataFromCodeなどとして作成すると、インスタンス化をどこで行うか選択肢が増える。

// codeからobjectを作成し、データを返すメソッドをよぶ

ClassMethod makeDataFromCode(code As %Integer) As user.data.User
{
    set data = ""
    set data = ##class(user.data.User).%OpenId( code )
    return ..makeData( data )
}

// インスタンス化のみ行う

ClassMethod Instance(code As %Integer) As user.data.User
{

    set data = ""
    set data = ##class(user.data.User).%OpenId( code )
    return data
}

ClassMethod errorTest(ByRef res As %Integer) As %Status
{
    set result = $$$OK

    try {
        set a=3

        if ('a) {
            set $ec=",Uerror003!!,"
        }
        

        //set a=b

        set res = a
    } catch e {
        w e.DisplayString()
        set result = e.AsStatus()
    }
    
    quit result
}

}
