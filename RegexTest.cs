using System;
using System.Collections;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.Text.RegularExpressions;
using Microsoft.SqlServer.Server;

public partial class UserDefinedFunctions
{

    [Microsoft.SqlServer.Server.SqlFunction(Name="RegexTest",IsDeterministic=true,DataAccess=DataAccessKind.None,IsPrecise=true)]
    public static SqlBoolean RegexTest(SqlString expression, SqlString pattern)
    {
        if(expression.IsNull || pattern.IsNull)
            return SqlBoolean.Null;

        return Regex.IsMatch(expression.Value, pattern.Value, RegexOptions.IgnoreCase);
        //return re.getPattern().isMatch(expression);
    }

    [Microsoft.SqlServer.Server.SqlFunction(Name = "RegexReplace", IsDeterministic = true, IsPrecise = true, DataAccess = DataAccessKind.None)]
    public static SqlString RegexReplace(SqlString expression, SqlString pattern, SqlString replacement)
    {
        if (expression.IsNull || pattern.IsNull || replacement.IsNull)
            return SqlString.Null;

        return Regex.Replace(expression.Value, pattern.Value, replacement.Value, RegexOptions.IgnoreCase);
        
    }


    [Microsoft.SqlServer.Server.SqlFunction(Name = "RegexMatch", IsDeterministic = true, IsPrecise = true, DataAccess = DataAccessKind.None)]
    public static SqlString RegexMatch(SqlString expression, SqlString pattern, SqlInt16 MatchNumber)
    {
        if (expression.IsNull || pattern.IsNull || MatchNumber.IsNull)
            return SqlString.Null;

        int MatchIndex = MatchNumber.Value - 1;

        MatchCollection cc = Regex.Matches(expression.Value, pattern.Value, RegexOptions.IgnoreCase);
        if (MatchIndex < cc.Count)
            return cc[MatchIndex].Value;
        else
            return SqlString.Null;
    }

    [Microsoft.SqlServer.Server.SqlFunction(Name = "RegexMatchGroup", IsDeterministic = true, IsPrecise = true, DataAccess = DataAccessKind.None)]
    public static SqlString RegexMatchGroup(SqlString expression, SqlString pattern, SqlInt16 MatchNumber, SqlInt16 GroupNumber)
    {
        if (expression.IsNull || pattern.IsNull || MatchNumber.IsNull || GroupNumber.IsNull)
            return SqlString.Null;

        int MatchIndex = MatchNumber.Value - 1;
        int GroupIndex = GroupNumber.Value;

        MatchCollection cc = Regex.Matches(expression.Value, pattern.Value, RegexOptions.IgnoreCase);
        if (MatchIndex < cc.Count)
            if(cc[MatchIndex].Groups.Count > GroupIndex)
                return cc[MatchIndex].Groups[GroupIndex].Value;
            else
                return SqlString.Null;
        else
            return SqlString.Null;
    }

    [Microsoft.SqlServer.Server.SqlFunction(Name = "RegexMatchIndex", IsDeterministic = true, IsPrecise = true, DataAccess = DataAccessKind.None)]
    public static SqlInt32 RegexMatchIndex(SqlString expression, SqlString pattern, SqlInt16 MatchNumber)
    {
        if (expression.IsNull || pattern.IsNull || MatchNumber.IsNull)
            return SqlInt32.Null;

        int MatchIndex = MatchNumber.Value - 1;

        MatchCollection cc = Regex.Matches(expression.Value, pattern.Value, RegexOptions.IgnoreCase);
        if (MatchIndex < cc.Count)
            return cc[MatchIndex].Index;
        else
            return SqlInt32.Null;
    }

    [SqlFunction(Name = "RegexMatchToTable", FillRowMethodName = "FillMatchRow",
     TableDefinition = "[Index] smallint, StartingPosition int, Length int, [Text] nvarchar(max)",
        DataAccess = DataAccessKind.None, IsDeterministic = true, IsPrecise = true)]
    public static IEnumerable RegexMatchToTable(SqlChars input, SqlString pattern)
    {
        return new MatchIterator(new string(input.Value), pattern.Value);
    }

    //[SuppressMessage("Microsoft.Design", "CA1021:AvoidOutParameters")]
    public static void FillMatchRow(object data,
        out SqlInt16 index, out SqlInt32 startingPos, out SqlInt32 Length, out SqlString text)
    {
        MatchNode node = (MatchNode)data;
        index = new SqlInt16((short)node.Index);
        text = new SqlString(node.Value);
        startingPos = new SqlInt32(node.StartingPos + 1);
        Length = new SqlInt32(node.Length);
    }



    internal class MatchNode
    {
        private int _index;
        public int Index { get { return _index; } }

        private int _startingPos;
        public int StartingPos { get { return _startingPos; } }


        private int _length;
        public int Length { get { return _length; } }

        private string _value;
        public string Value { get { return _value; } }

        public MatchNode(int index, string value, int StartingPos, int Length)
        {
            _index = index;
            _value = value;
            _startingPos = StartingPos;
            _length = Length;
        }
    }
    
    internal class MatchIterator : IEnumerable
    {
        private Regex _regex;
        private string _input;

        public MatchIterator(string input, string pattern)
        {
            _regex = new Regex(pattern);
            _input = input;
        }

        public IEnumerator GetEnumerator()
        {
            int index = 0;
            Match current = null;
            do
            {
                current = (current == null) ?
                    _regex.Match(_input) : current.NextMatch();
                if (current.Success)
                {
                    yield return new MatchNode(++index, current.Value, current.Index, current.Length);
                }
            }
            while (current.Success);
        }
    }


    //caching seems to be done automatically by the regex engine.  None of the below is necessary (and would require 'UNSAFE' permissions).
    //private static ArrayList RegularExpressions = new ArrayList();
    //private static int MaxNumberOfREs = 10;

    //private class RE
    //{
    //    public Regex re;
    //    public string pattern;
    //    public RE(string pat)
    //    {
    //        pattern = pat;
    //        re = new Regex(pattern);
    //    }
    //    public static boolean operator == (RE l, RE r)
    //    {
    //        //if(typeof(object) != typeof(this))
    //        //    return false;
    //        return l.pattern == r.pattern;
    //    }
    //}

    //private static Regex getRe(string pattern)
    //{
    //    int i;
    //    RE re;

    //    if (i = RegularExpressions.IndexOf(pattern))
    //    {
    //        return RegularExpressions[i];
    //    }


    //    re = new RE(pattern);

    //    if (RegularExpressions.Count >= MaxNumberOfREs)
    //    {
    //        RegularExpressions.RemoveAt[0];
    //    }

    //    RegularExpressions.Add(re);
    //    return re.re;

    //}


};