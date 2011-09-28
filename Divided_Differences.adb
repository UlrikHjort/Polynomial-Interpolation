-------------------------------------------------------------------------------
--                                                                           --
--                         Polynomial Interpolation                          --
--                                                                           --
--                         Divided_Differences.adb                           --
--                                                                           --
--                                  BODY                                     --
--                                                                           --
--                   Copyright (C) 1996 Ulrik Hørlyk Hjort                   --
--                                                                           --
--  Polynomial Interpolation is free software;  you can  redistribute it     --
--  and/or modify it under terms of the  GNU General Public License          --
--  as published  by the Free Software  Foundation;  either version 2,       --
--  or (at your option) any later version.                                   --
--  Polynomial Interpolation is distributed in the hope that it will be      --
--  useful, but WITHOUT ANY WARRANTY;  without even the  implied warranty    --
--  of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                  --
--  See the GNU General Public License for  more details.                    --
--  You should have  received  a copy of the GNU General                     --
--  Public License  distributed with Yolk.  If not, write  to  the  Free     --
--  Software Foundation,  51  Franklin  Street,  Fifth  Floor, Boston,       --
--  MA 02110 - 1301, USA.                                                    --
--                                                                           --
-------------------------------------------------------------------------------

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with Ada.Strings.Fixed;

package body Divided_Differences is


   --------------------------------------------------------------------------
   -- Returns the value F(x) where F is given by Cofficients and x by X.
   --------------------------------------------------------------------------
   function Error_Test(Cofficients : in Float_Array_T; X : in Float; FX : in Float)
                      return Float is

      Res   : Float := 0.0;
   begin
       for I in Cofficients'First .. Cofficients'Last loop
          Res :=  Res + (Cofficients(I) * (X ** (I-1)));
       end loop;
       Ada.Text_IO.New_Line;Ada.Text_IO.New_Line;
       Ada.Text_IO.Put("(X,Y) => (");
       Ada.Float_Text_IO.Put(X, EXP =>0);
       Put(" ,");
       Ada.Float_Text_IO.Put(Res, EXP =>0);
       Ada.Text_IO.Put(")");Ada.Text_IO.New_Line;

       return Abs((Res - FX) / FX);
   end Error_Test;



   ------------------------------------------------------
   -- Trim integer image fro white leading whitespaces
   ------------------------------------------------------
   function Trim_Image (I : in Integer) return String is
   begin -- My_Image
      return Ada.Strings.Fixed.Trim (Integer'Image (I), Ada.Strings.Left);
   end Trim_Image;

   ------------------------------------------------------
   -- Returns the size of the data file in lines.
   ------------------------------------------------------
   function Get_Data_Size(Filename : in String) return Integer is
      Data_File  : FILE_TYPE;
      Size       : Integer := 0;
      Data_Value : Float   := 0.0;

   begin
      Open(Data_File, In_File, Filename);

      while not End_Of_File(Data_File) loop
         if End_Of_Line(Data_File) then
            Skip_Line(Data_File);
            Size := Size +1;
         else
            Get(Data_File, Data_Value);
            Get(Data_File, Data_Value);
         end if;
      end loop;

      Close(Data_File);

      return Size;
   end Get_Data_Size;


   ----------------------------------------------------------
   -- Read the data set from the file Filename containing the
   -- x values and the F(x) values for the given polynomial
   ----------------------------------------------------------
   procedure Read_Data(Filename: in String; X_Values : in out  Float_Array_T;
                                            FX_Values : in out  Float_Array_T) is

      Data_File  : FILE_TYPE;
      Index : Positive := 1;

   begin
      Open(Data_File, In_File, Filename);

      while not End_Of_File(Data_File) loop
         if End_Of_Line(Data_File) then
            Skip_Line(Data_File);
         else
            Get(Data_File, X_Values(Index));
            Get(Data_File, FX_Values(Index));
            Index := Index +1;
         end if;
      end loop;

      Close(Data_File);
   exception
      -- Constraint_Error aaised if empty lines in
      -- the data file. We ignore this.
      when Constraint_Error =>
      Close(Data_File);
   end Read_Data;



   ------------------------------------------------------
   -- Interpolate the data set given by Data_Set_Name
   -- by a Newton's divided differences interpolation
   -- polynomial.
   ------------------------------------------------------
   procedure Interpolate(Data_Set_Name : String) is

      Data_Set_Size : constant Positive := Get_Data_Size(Data_Set_Name);
      Degree        : constant Positive := Data_Set_Size-1;

      subtype Array_Range is Positive range  1..Data_Set_Size;

      X_Values    : Float_Array_T (Array_Range) := (others => 0.0);
      FX_Values   : Float_Array_T (Array_Range) := (others => 0.0);

      Data_Values : Float_Array_T (Array_Range) := (others => 0.0);
      Diff_Values : Float_Array_T (Array_Range) := (others => 0.0);
      Cofficients : Float_Array_T (Array_Range) := (others => 0.0);

      Power       : Float := 0.0;
      FirstTerm   : Boolean := False;
      Error       : Float := 0.0;
   begin
       Read_Data(Data_Set_Name, X_Values, FX_Values);

       -- Copy f(x0) values into data array:
      for I in Array_Range loop
         Data_Values(I) := FX_Values(I);
      end loop;

      for I in reverse 0 .. Degree loop
         -- Copy Data values to difference array:
         for J in Array_Range loop
           Diff_Values(J) := Data_Values(J);
         end loop;


         for J in 2 .. I+1 loop
            for K in Array_Range'First .. (Data_Set_Size-J+1) loop
                 Diff_values(k) := (Diff_Values(K+1) - Diff_Values(K)) /
                   (X_Values(K+J-1) - X_Values(K));
            end loop;
         end loop;

         Cofficients(I+1) := 0.0;
         for J in Array_Range'First .. (Data_Set_Size-I) loop
             Cofficients(I+1) := Cofficients(I+1) + Diff_values(J);
         end loop;
         Cofficients(I+1) := Cofficients(I+1) / Float(Data_Set_Size-I);

         for J in Array_Range loop
            Power := 1.0;
            for K in Array_Range'First .. (I) loop
               Power := Power * X_values(J);
            end loop;
            Data_Values(J) := Data_Values(J) -(Cofficients(I+1) * Power);
         end loop;
      end loop;


     for I in reverse Array_Range loop
        -- Only Write Terms where cofficent /= 0
        if Cofficients(I) /= 0.0 then
             if (Cofficients(I) > -1.0) and FirstTerm then
                 Ada.Text_IO.Put(" +");
             end if;
             FirstTerm := True;

             -- Don't write cofficients = 1
             if Cofficients(I) /= 1.0 then
                Ada.Float_Text_IO.Put(Cofficients(I), EXP =>0);
                Ada.Text_IO.Put(" ");
             end if;
             if I = 2 then
                 Ada.Text_IO.Put("X ");
             elsif I > 2 then
                 Ada.Text_IO.Put("X^" & Trim_Image(I-1) & " ");
             end If;
         end if;
      end loop;

      for I in X_Values'First .. X_Values'Last loop
         Error := Error_Test(Cofficients,X_Values(I), FX_Values(I));
         Put("Accuracy: ");
         Put(Item => (1.0-Error), EXP => 0);
         New_Line;
      end loop;
   End Interpolate;
End Divided_Differences;
