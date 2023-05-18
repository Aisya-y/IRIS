Class cstm.data.Customer Extends %Persistent
{

Property code As %Integer(MAXVAL = 9999, MINVAL = 1000) [ Required ];

Property name As %String [ Required ];

Property kanaName As %String [ Required ];

Property birthDay As %Date;

Property signUpDay As %Date;

Property seibetsu As %Char(VALUELIST = ",0,1,2,9");

Property number As array Of %String;

Index customerIdx On code [ IdKey, Unique ];

Index customerKIdx On (birthDay, code);

Storage Default
{
<Data name="CustomerDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>name</Value>
</Value>
<Value name="3">
<Value>kanaName</Value>
</Value>
<Value name="4">
<Value>birthDay</Value>
</Value>
<Value name="5">
<Value>signUpDay</Value>
</Value>
<Value name="6">
<Value>seibetsu</Value>
</Value>
</Data>
<Data name="number">
<Attribute>number</Attribute>
<Structure>subnode</Structure>
<Subscript>"number"</Subscript>
</Data>
<DataLocation>^cstm.data.CustomerD</DataLocation>
<DefaultData>CustomerDefaultData</DefaultData>
<IdLocation>^cstm.data.CustomerD</IdLocation>
<IndexLocation>^cstm.data.CustomerI</IndexLocation>
<StreamLocation>^cstm.data.CustomerS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
