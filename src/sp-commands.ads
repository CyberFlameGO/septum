with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with SP.Searches;
with SP.Strings;            use SP.Strings;

package SP.Commands is

    pragma Elaborate_Body;

    function Execute
        (Srch : in out SP.Searches.Search; Command_Name : Unbounded_String; Parameters : String_Vectors.Vector)
         return Boolean;

end SP.Commands;
