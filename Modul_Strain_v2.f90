   
    Module DataType
    implicit none 
integer, save::met
integer, save:: Nt,Nat1,Nat2,Nat3,Nat13,htj ! htj=2 for A/B QD type; htj=3 for AB/AC QD type.
integer, save:: QD, N1in, N3out, N2in, N4out, Casex
real*8, save::a1,a2, WL, epscap, Geom_par1, Geom_par2, Geom_par3
Real*8,save:: Rt, Rq ! Rt is torus radius (center to center of tube distance); Rq is tube radius
Real*8,save:: Rc, h, htc !Rc is cone radius or half of the pyramid base;  h is cone or pyramid height; htc is the height of truncated cone
Real*8,save:: RCO, RCS !RCO is core, RCS is core+shell radius
Real*8,save:: msfit
integer, save::nxp,nx, ny, nzmin, nzmax
Real*8,save:: C11out,C12out,C11in,C12in
Real*8,save:: ac12,ac13,bc12,bc13,dc12,dc13
    end Module DataType      
