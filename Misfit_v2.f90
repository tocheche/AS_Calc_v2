!*******************************************************************
Subroutine Misfit(Rcut,Rstart,xr,N13)
! 
use DataType
integer, parameter :: dp = kind(1.0d0)
Real(dp):: T1(N13,3),T2(N13+1:N13+N2IN,3),T3(N13+N2IN+1:N13+N2IN+N4OUT,3),T23(N2IN+N4OUT,3) !lists with coords of Ga(T1),Sb(T2),As(T3), and Sb+As(T23).
Real(dp):: T240(N13,8),TT240(N13,8),T260(N2IN,8),TT260(N2IN,8),TT280(N4OUT,8),T280(N4OUT,8) !reshaped T1,T2,T3.
Real(dp)::alfa1(N13,5:8),beta1(N13,5:8),did1(N13,5:8) !elastic parameters,bulk distance between Ga (PA) atoms and NA (Sb orAs).
integer:: nghb1(N13,5:8) !NA type for Ga atoms.
Real(dp)::alfa2(N13+1:N13+N2IN,5:8),beta2(N13+1:N13+N2IN,5:8),did2(N13+1:N13+N2IN,5:8) !elastic parameters,bulk distance between Sb atoms (PA) and Ga (NA).
Real(dp)::alfa3(N13+N2IN+1:N13+N2IN+N4OUT,5:8),beta3(N13+N2IN+1:N13+N2IN+N4OUT,5:8),did3(N13+N2IN+1:N13+N2IN+N4OUT,5:8) !elastic parameters,bulk distance between As atoms (PA) and Ga (NA).
Real(dp):: rn(4*(N13+N2IN+N4OUT),3),rp(N13+N2IN+N4OUT,3) !NA, PA coords.
Real(dp):: alfa(4*(N13+N2IN+N4OUT)),beta(4*(N13+N2IN+N4OUT)),did(4*(N13+N2IN+N4OUT)),dpn(4*(N13+N2IN+N4OUT)) !introduced to build a table which collects together all elastic parameters, bulk distances, PA-NA distances; the terms entering in Uel & DUel expressions are easier addressed from the table.
Integer:: N13,nghb(4*N13)
      Integer:: TTNb1(N13,8),TNb1(N13,8),TTNb2(N2IN,8),TNb2(N2IN,8),TTNb3(N4OUT,8),TNb3(N4OUT,8)
      Integer:: TTNb(N13+N2IN+N4OUT,5),TNb(N13+N2IN+N4OUT,5)
      Integer::i,j,t, Rstart
      Logical::Logs23(N13,5:8)
Real(dp):: xr(3*(N13+N2IN+N4OUT))
Real(dp):: PA2(4*N13,3), PA3(4*N2IN,3),PA4(4*N4OUT,3)
Real(dp)::  Rcut(Rstart) ! Rcut(5)
integer::k,L,LL,q,qq,jj,ii,qqq, q1, q2
!****************************************************
!
!I.  One collects the data for Uel & DUel calculus
!I.1 First, atom coords:
continue

do i=1,N13
    T1(i,1)=xr(3*(i-1)+1);T1(i,2)=xr(3*(i-1)+2);T1(i,3)=xr(3*(i-1)+3) !Ga atom coords
end do
do i=N13+1,N13+N2IN
    T2(i,1)=xr(3*(i-1)+1);T2(i,2)=xr(3*(i-1)+2);T2(i,3)=xr(3*(i-1)+3) !Sb atom coords
    T23(i-N13,1)=xr(3*(i-1)+1);T23(i-N13,2)=xr(3*(i-1)+2);T23(i-N13,3)=xr(3*(i-1)+3) !Sb atom coords
end do
do i=N13+N2IN+1,N13+N2IN+N4OUT
    T3(i,1)=xr(3*(i-1)+1);T3(i,2)=xr(3*(i-1)+2);T3(i,3)=xr(3*(i-1)+3) !As atom coords
    T23(i-N13,1)=xr(3*(i-1)+1);T23(i-N13,2)=xr(3*(i-1)+2);T23(i-N13,3)=xr(3*(i-1)+3) !As atom coords
end do
!---------------------------------------------------------------
!
    rewind(111) !file 111 provides the indexes of each atom and its first 4 neighbors for the initial configuration
    read(111,*)TTNb
    TNb=RESHAPE(TTNb, (/N13+N2IN+N4OUT,5/), ORDER = (/2,1/)) !TNb is the transpose of TTNb
continue
!===============================================
!
!I.2 Second, to x coords of each atom one adds the neighbors coords
open(unit=501,file='temp501.dat',status='replace') !for tests & DerivExist(..).; PA position & its first 4 NAs in final configuration & ordering
!
q=0 !
!=================================================
!*: For GaSb/GaAs: Ga; For InAs/GaAs: As; For Si/C: Si(N1IN_At1)+C(N13-N1IN_At3 OUT QD) as PA.
Open (1240,file='temp240.dat',status='old') !reading temp240.dat (generated by Sortx123) which contains 4 distances (d213) between PA(Ga)-NA(Sb or As) & 4 permutation indexes obtained by sorting.
read(1240,*) TT240
T240=RESHAPE(TT240, (/N13,8/), ORDER = (/2,1/))
qqq=0;q1=0;q2=0
do i=1,N13
    do j=5,8
!---------------------------------------------
            TNb1(i,j)=TNb(i,j-3)-N13 !Example: TNb(i=1,j-3=2)=element_12 in matrix file 111
            continue
!---------------------------------------------
    Logs23(i,j)=TNb1(i,j).le.N2IN !if TNb1(i,j).le.N2IN, then neighbor is atom2(Sb), else neighbor is atom3(As); [KP1]: decides the type of NA for Ga as a PA.
    If(Logs23(i,j)) then
        if(T240(i,j-4) .le. Rcut(Rstart)) then !Rcut(Rstart)=max search radius for neighbors in the Rstart-th minimization cycle
        alfa1(i,j)=ac12 !atom1-atom2 bond
        beta1(i,j)=bc12 !atom1-atom2 bond
        did1(i,j)=dc12  !atom1-atom2 bond length
        nghb1(i,j)=2     !neighbor type
        else
        alfa1(i,j)=0 !cancels contribution to Uel, DU if rpn>Rcut(Rstart) 
        beta1(i,j)=0 ! -II-
        did1(i,j)=dc12  !atom1-atom2 bond length
        nghb1(i,j)=2     !neighbor type for QD.ne.4
       end if        
    Else
        if(T240(i,j-4) .le. Rcut(Rstart)) then  !Rcut(Rstart)=max search radius for neighbors in the Rstart-th minimization cycle
        alfa1(i,j)=ac13 !atom1-atom3 bond
        beta1(i,j)=bc13 !atom1-atom3 bond
        did1(i,j)=dc13  !atom1-atom3 bond length
        nghb1(i,j)=3     !neighbor type for QD.ne.4
        else
        alfa1(i,j)=0 !cancels contribution to Uel, DU if rpn>Rcut(Rstart) 
        beta1(i,j)=0 !-II-
        did1(i,j)=dc13  !atom1-atom3 bond length
        nghb1(i,j)=3     !neighbor type for QD.ne.4
        end if        
    End If
!-----------------------------------------
!
    t=TNb1(i,j)
        q=q+1
        qq=(q-1)/4+1
        alfa(q)=alfa1(i,j);beta(q)=beta1(i,j);did(q)=did1(i,j) !;dpn(q)=T240(i,j-4); 
        rp(qq,1)=T1(i,1);rp(qq,2)=T1(i,2);rp(qq,3)=T1(i,3)  
        rn(q,1)=T23(t,1);rn(q,2)=T23(t,2);rn(q,3)=T23(t,3); nghb(q)=nghb1(i,j)
        dpn(q)=dsqrt((rp(qq,1)-rn(q,1))**2+(rp(qq,2)-rn(q,2))**2+(rp(qq,3)-rn(q,3))**2) 
!write(501,3101) alfa(q),beta(q),did(q),dpn(q),rp(qq,1),rp(qq,2),rp(qq,3),rn(q,1),rn(q,2),rn(q,3),1,nghb(q), q !for tests & DerivExist(..).
!
IF(QD==1.or.QD==2.or.QD==21.or.QD==3.or.htj==3) then
    If(qq .le. N1IN) then
    if (alfa(q)==0.or.(dpn(q).lt.dc12*(1-msfit)).or. (dpn(q).gt.dc12*(1+msfit))) then !one counts and records dislocation coords of NAs of Ga//As as PA.
        qqq=qqq+1
        PA2(qqq,1)=rp(qq,1);PA2(qqq,2)=rp(qq,2);PA2(qqq,3)=rp(qq,3)
        write(502,*) PA2(qqq,1),PA2(qqq,2),PA2(qqq,3) !coords of Ga as PA where dislocations occur in relaxed config.
    end if
    End If
!
    If(qq .gt. N1IN) then
    if (alfa(q)==0.or.(dpn(q).lt.dc13*(1-msfit)).or. (dpn(q).gt.dc13*(1+msfit))) then !one counts and records dislocation coords of NAs of Ga//As as PA.
        qqq=qqq+1
        PA2(qqq,1)=rp(qq,1);PA2(qqq,2)=rp(qq,2);PA2(qqq,3)=rp(qq,3)
        write(502,*) PA2(qqq,1),PA2(qqq,2),PA2(qqq,3) !coords of Ga as PA where dislocations occur in relaxed config.    
    end if    
    End IF
END IF
!
IF(QD==4 .and. htj==2 ) then !for core-shell of type Si/C (At1At2/At3At4) to count only Si(At1) IN.
    If (qq .le. N1IN) then 
        if (alfa(q)==0.or.(dpn(q).lt.dc12*(1-msfit)).or. (dpn(q).gt.dc12*(1+msfit))) then !coords of Si(At1) as PA where dislocations occur in relaxed config;
        q1=q1+1
        PA2(q1,1)=rp(qq,1);PA2(q1,2)=rp(qq,2);PA2(q1,3)=rp(qq,3)
        write(571,*) PA2(q1,1),PA2(q1,2),PA2(q1,3) !coords of Si(At1) IN as PA where dislocations occur in relaxed config.
        end if
    End IF
!
    If (qq .gt. N1IN) then !for core-shell of type Si/C (At1At2/At3At4) to count only C(At3) OUT.
        if (alfa(q)==0.or.(dpn(q).lt.dc13*(1-msfit)).or. (dpn(q).gt.dc13*(1+msfit))) then !coords of C(At3) as PA where dislocations occur in relaxed config.
        q2=q2+1
        PA2(q2,1)=rp(qq,1);PA2(q2,2)=rp(qq,2);PA2(q2,3)=rp(qq,3)
        write(573,*) PA2(q2,1),PA2(q2,2),PA2(q2,3) !coords of C(At3) OUT as PA where dislocations occur in relaxed config.
        end if
    End IF
End IF
3101 Format(10F12.6,2I2,I7)
!    continue
    end do
end do
close(1240)
continue
!
!=====================================================
!
!**: For GaSb/GaAs: Sb; For InAs/GaAs: In; For Si/C: Si as PA.
qqq=0
Open (1260,file='temp260.dat',status='old') !reading temp260.dat (generated by Sortx123) which contains 4 distances (d21) between PA(Sb)-NA(Ga) & 4 permutation indexes obtained by sorting.
read(1260,*) TT260
T260=RESHAPE(TT260, (/N2IN,8/), ORDER = (/2,1/))
do i=N13+1,N13+N2IN
    do j=5,8
!---------------------------------------------
            TNb2(i-N13,j)=TNb(i,j-3)
!---------------------------------------------
        t=TNb2(i-N13,j)
            if(T260(i-N13,j-4) .le. Rcut(Rstart)) then !Rcut(Rstart)=max search radius for neighbors in the Rstart-th minimization cycle
            alfa2(i,j)=ac12 !atom2-atom1 bond
            beta2(i,j)=bc12 !atom2-atom1 bond
            did2(i,j)=dc12  !atom2-atom1 bond length
            else
            alfa2(i,j)=0 !cancels contribution to Uel & to DU if rpn>Rcut(Rstart)
            beta2(i,j)=0 !-II-
            did2(i,j)=dc12  !atom2-atom1 bond length
            end if    
!---------------------------------
!            
        q=q+1
        qq=(q-1)/4+1
        alfa(q)=alfa2(i,j);beta(q)=beta2(i,j);did(q)=did2(i,j) !;dpn(q)=T260(i-N13,j-4);
        rp(qq,1)=T2(i,1);rp(qq,2)=T2(i,2);rp(qq,3)=T2(i,3)
        rn(q,1)=T1(t,1);rn(q,2)=T1(t,2);rn(q,3)=T1(t,3)
        dpn(q)=dsqrt((rp(qq,1)-rn(q,1))**2+(rp(qq,2)-rn(q,2))**2+(rp(qq,3)-rn(q,3))**2)
!write(501,3101) alfa(q),beta(q),did(q),dpn(q),rp(qq,1),rp(qq,2),rp(qq,3),rn(q,1),rn(q,2),rn(q,3),2,1, q !for tests & DerivExist(..).
!
IF(QD==1.or.QD==2.or.QD==21.or.QD==3.or.htj==3) then !command A1260
!#IF(QD==1.or.QD==2.or.QD==21.or.QD==3) then !command B1260
    if (alfa(q)==0.or.(dpn(q).lt.dc12*(1-msfit)).or. (dpn(q).gt.dc12*(1+msfit))) then !one counts and records dislocation coords of NAs of Sb as PA.    
       qqq=qqq+1
        PA3(qqq,1)=rp(qq,1);PA3(qqq,2)=rp(qq,2);PA3(qqq,3)=rp(qq,3)
        write(503,*) PA3(qqq,1),PA3(qqq,2),PA3(qqq,3) !coords of Sb as PA where dislocations occur in relaxed config.
    end if
End If 
!
!Activate command B1260, deactivate command B1260 and below commented commands '!#' if zooming dislocations of In//Sb as PA is desired:
!#IF(QD==4.and.htj==3) then ! for InAs/GaAs core-shell QDs to have visible In atoms 'misfit' is changed.     
!#!   if (alfa(q)==0.or.(dpn(q).lt.dc12*(1-msfit/2.4)).or. (dpn(q).gt.dc12*(1+msfit/2.4))) then !one counts and records dislocation coords of NAs of Ga//As as PA.            
!#      qqq=qqq+1
!#        PA3(qqq,1)=rp(qq,1);PA3(qqq,2)=rp(qq,2);PA3(qqq,3)=rp(qq,3)
!#        write(503,*) PA3(qqq,1),PA3(qqq,2),PA3(qqq,3) !coords of Sb as PA where dislocations occur in relaxed config.
!#    end if
!#End If 
!
IF(QD==4 .and. htj==2) then !for core-shell of type Si/C (At1At2/At3At4) to count only Si(At2) IN.    
        if (alfa(q)==0.or.(dpn(q).lt.dc12*(1-msfit)).or. (dpn(q).gt.dc12*(1+msfit))) then !one counts and records dislocation coordinates in Sb//In as PA.
        qqq=qqq+1
            PA3(qqq,1)=rp(qq,1);PA3(qqq,2)=rp(qq,2);PA3(qqq,3)=rp(qq,3)
           write(572,*) PA3(qqq,1),PA3(qqq,2),PA3(qqq,3) !coords of Si(At2) IN as PA where dislocations occur in relaxed config.
        end if
    End IF    
!   
    end do
end do
close(1260) !close(503)
continue
!
!====================================================
!
!***: For GaSb/GaAs: As; For InAs/GaAs: As; For Si/C: C as PA.
qqq=0
Open (1280,file='temp280.dat',status='old') !reading temp280.dat (generated by Sortx123) which contains 4 distances (d31) between PA(As)-NA(Ga) & 4 permutation indexes obtained by sorting.
read(1280,*) TT280
T280=RESHAPE(TT280, (/N4OUT,8/), ORDER = (/2,1/))
do i=N13+N2IN+1,N13+N2IN+N4OUT
    do j=5,8
!---------------------------------------------
            TNb3(i-N13-N2IN,j)=TNb(i,j-3)
!---------------------------------------------
        t=TNb3(i-N13-N2IN,j)
            if(T280(i-N13-N2IN,j-4) .le. Rcut(Rstart)) then !Rcut(Rstart)=max search radius for neighbors in the Rstart-th minimization cycle
            alfa3(i,j)=ac13 !atom3-atom1 bond
            beta3(i,j)=bc13 !atom3-atom1 bond
            did3(i,j)=dc13  !atom3-atom1 bond length
            else
            alfa3(i,j)=0 !cancels contribution to Uel & to DU if rpn>Rcut(Rstart)
            beta3(i,j)=0 !-II-
            did3(i,j)=dc13  !atom3-atom1 bond length
            end if            
!---------------------------------
If(test==1)then
            t=TNb3(i-N13-N2IN,j)
            alfa3(i,j)=ac13 !atom3-atom1 bond
            beta3(i,j)=bc13 !atom3-atom1 bond
            did3(i,j)=dc13  !atom3-atom1 bond length      
End If           
!---------------------------------
!            
        q=q+1
        qq=(q-1)/4+1 
        alfa(q)=alfa3(i,j);beta(q)=beta3(i,j);did(q)=did3(i,j) !;dpn(q)=T280(i-N13-N2IN,j-4);
        rp(qq,1)=T3(i,1);rp(qq,2)=T3(i,2);rp(qq,3)=T3(i,3)
        rn(q,1)=T1(t,1);rn(q,2)=T1(t,2);rn(q,3)=T1(t,3);
        dpn(q)=dsqrt((rp(qq,1)-rn(q,1))**2+(rp(qq,2)-rn(q,2))**2+(rp(qq,3)-rn(q,3))**2)
!write(501,3101) alfa(q),beta(q),did(q),dpn(q),rp(qq,1),rp(qq,2),rp(qq,3),rn(q,1),rn(q,2),rn(q,3),3,1, q !for tests & DerivExist(..).  
!
IF(QD==1.or.QD==2.or.QD==21.or.QD==3.or.htj==3) then
    if (alfa(q)==0.or.(dpn(q).lt.dc13*(1-msfit)).or. (dpn(q).gt.dc13*(1+msfit))) then !one counts and records dislocation coords of NAs of Ga//As as PA.
        qqq=qqq+1
        PA4(qqq,1)=rp(qq,1);PA4(qqq,2)=rp(qq,2);PA4(qqq,3)=rp(qq,3)
        write(504,*) PA4(qqq,1),PA4(qqq,2),PA4(qqq,3) !coords of As as PA where dislocations occur in relaxed config.
    end if
End If
!
IF(QD==4 .and. htj==2 ) then !for core-shell of type Si/C (At1At2/At3At4) to count only C(At4) OUT.
    if (alfa(q)==0.or.(dpn(q).lt.dc13*(1-msfit)).or. (dpn(q).gt.dc13*(1+msfit))) then !one counts and records dislocation coordinates in Sb//In as PA.
    qqq=qqq+1
             PA4(qqq,1)=rp(qq,1);PA4(qqq,2)=rp(qq,2);PA4(qqq,3)=rp(qq,3)
           write(574,*) PA4(qqq,1),PA4(qqq,2),PA4(qqq,3) !coords of SC(At4) OUT as PA where dislocations occur in relaxed config.
    end if
End IF        
!        
    end do
end do
!
close(1280) !;close(504)
close(501)
continue
!-------------------------------------------------------------------- 
!
    End Subroutine Misfit
!*****************************************************************
!    
subroutine elastic_ct
use DataType
!integer, parameter :: Real 8 ! dp = kind(1.0d0)
!
!bond-stretching force constants used in U, DU calculus
!
    ac13=(C11out+3*C12out)*a1/4 !alpha1 GaAs OUT
    bc13=(C11out-C12out)*a1/4 !beta1 GaAs;C OUT
    ac12=(C11in+3*C12in)*a2/4 !alpha2 GaSb/InAs;Si IN
    bc12=(C11in-C12in)*a2/4   !beta2 GaSb/InAs;Si IN
!
    dc12=a2*dsqrt(3d0)/4 !GaSb/InAs;Si IN
    dc13=a1*dsqrt(3d0)/4 !GaAs;C OUT
!
!a1-GaAs;C (OUT) < a2-GaSb/InAs;Si(IN)
!ac12=ac21,ac13=ac31,bc12=bc21,bc13=bc31,dc12=dc21,dc13=dc31
end Subroutine elastic_ct
!******************************************************************