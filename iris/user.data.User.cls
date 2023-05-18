Class user.data.User Extends %Persistent
{

/// Description
Property code As %Integer(MAXVAL = 999) [ Required ];

Property name As %String;

Property kanaName As %String;

Property birthDay As %Date;

Property seibetsu As %Char(VALUELIST = ",0,1,3,9");

Index userIndex On code [ IdKey, Unique ];

Storage Default
{
<Data name="UserDefaultData">
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
<Value>seibetsu</Value>
</Value>
</Data>
<DataLocation>^user.data.UserD</DataLocation>
<DefaultData>UserDefaultData</DefaultData>
<ExtentSize>2</ExtentSize>
<IdLocation>^user.data.UserD</IdLocation>
<IndexLocation>^user.data.UserI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="birthDay">
<AverageFieldSize>4</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<Property name="code">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="kanaName">
<AverageFieldSize>11</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<Property name="name">
<AverageFieldSize>11</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<Property name="seibetsu">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<SQLMap name="userIndex">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^user.data.UserS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
