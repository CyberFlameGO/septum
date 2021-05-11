package body SP.Contexts is

    function From
        (File_Name : String; Line : Natural; Num_Lines : Natural; Context_Width : Natural) return Context_Match is
        Minimum : constant Positive :=
            (if Context_Width > Num_Lines or else Line - Context_Width < 1 then 1 else Line - Context_Width);
        Maximum : constant Positive :=
            (if Context_Width > Num_Lines or else Line + Context_Width > Num_Lines then Num_Lines
             else Line + Context_Width);
    begin
        return C : Context_Match do
            C.File_Name := Ada.Strings.Unbounded.To_Unbounded_String (File_Name);
            C.Internal_Matches.Insert (Line);
            C.Minimum := Minimum;
            C.Maximum := Maximum;
        end return;
    end From;

    function Is_Valid (C : Context_Match) return Boolean is
    begin
        return
            (C.Minimum <= C.Maximum and then not C.Internal_Matches.Is_Empty
             and then C.Minimum <= C.Internal_Matches.First_Element
             and then C.Internal_Matches.Last_Element <= C.Maximum);
    end Is_Valid;

    function Real_Min (C : Context_Match) return Positive is (C.Internal_Matches.First_Element);
    function Real_Max (C : Context_Match) return Positive is (C.Internal_Matches.Last_Element);

    function Overlap (A, B : Context_Match) return Boolean is
        A_To_Left_Of_B  : constant Boolean  := A.Maximum < B.Minimum;
        A_To_Right_Of_B : constant Boolean  := B.Maximum < A.Minimum;
        New_Min         : constant Positive := Positive'Max (A.Minimum, B.Minimum);
        New_Max         : constant Positive := Positive'Min (A.Maximum, B.Maximum);
        use Ada.Strings.Unbounded;
    begin
        return
            A.File_Name = B.File_Name and then not (A_To_Left_Of_B or else A_To_Right_Of_B)
            and then
            (New_Min <= Real_Min (A) and then New_Min <= Real_Min (B) and then Real_Max (A) <= New_Max
             and then Real_Max (B) <= New_Max);
    end Overlap;

    function Contains (A : Context_Match; Line_Num : Positive) return Boolean is
    begin
        return A.Minimum <= Line_Num and then Line_Num <= A.Maximum;
    end Contains;

    function Merge (A, B : Context_Match) return Context_Match is
        use Line_Matches;
    begin
        return C : Context_Match do
            C.File_Name        := A.File_Name;
            C.Internal_Matches := A.Internal_Matches or B.Internal_Matches;
            C.Minimum          := Positive'Max (A.Minimum, B.Minimum);
            C.Maximum          := Positive'Min (A.Maximum, B.Maximum);
        end return;
    end Merge;

end SP.Contexts;
