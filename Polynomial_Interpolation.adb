-------------------------------------------------------------------------------
--                                                                           --
--                         Polynomial Interpolation                          --
--                                                                           --
--                       Polynomial_Interpolation.adb                        --
--                                                                           --
--                                  MAIN                                     --
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
with Divided_Differences; use Divided_Differences;
with Ada.Text_IO; use Ada.Text_IO;

Procedure  Polynomial_Interpolation is
begin
   Put_Line("**** Testing X^2 Polynomial Interpolation:");
   Put_Line("Expecting: X^2");
   Put("Result: ");
   Interpolate("./data/Poly_X2.dat");
   New_Line;

   New_Line;
   Put_Line("**** Testing X^3 + X^2 + X - 1 Polynomial Interpolation:");
   Put_Line("Expecting: X^3 + X^2 + X - 1 ");
   Put("Result: ");
   Interpolate("./data/Poly_X3.dat");
   New_Line;

   New_Line;
   Put_Line("**** Testing Accuracy Error Polynomial Interpolation:");
   Put_Line("Expecting: Accuracy Error: ");
   Put("Result: ");
   Interpolate("./data/Poly_Error.dat");
   New_Line;
  end Polynomial_Interpolation;

