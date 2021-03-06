\ BigZ

s" bigintegers.4th" included
s" primecounting.4th" included
s" nestedsets.4th" included

\ cond ( n -- flag )
: sqr dup sqrtf dup * = ;
: sqrfree dup radical = ;
: twinprime dup isprime over 2 + isprime rot 2 - isprime or and ;  
: singleprime dup isprime swap twinprime 0= and ;
: semiprime bigomega 2 = ;
: primepower smallomega 1 = ;
: biprime smallomega 2 = ;

: 2sqsum  dup * swap dup * + ;
: 3sqsum  dup * rot dup * rot dup * + + ;
: 4sqsum  3sqsum swap dup * + ;
: 5sqsum  4sqsum swap dup * + ;  \ a b c d e -- a²+b²+c²+d²+e²
: <<  over > -rot < and ;  \ a<b<c
: <<=  over >= -rot <= and ;
: isp  isprime ;
: r2p  isprime swap isprime and ;
: r3p  isprime -rot isprime swap isprime and and ;
: fi postpone else postpone false postpone then ; immediate

\ cond ( m n -- flag )
: coprime ugcd 1 = ;
: cop  coprime ;
: divide swap mod 0= ; 

: factorset \ n -- set
  dup 1 = if >zst -3 >zst exit then
  primefactors locals| n |
  n 0 do >zst loop
  n 2* negate >zst 
  set-sort 
  zst> 1- >zst ;

: set-of-factors \ s -- s'
  0 >xst
  foreach
  do zst> factorset zfence xzmerge loop
  xst zst setmove ;

\ testing for small (fast) single number divisors
\ of big number w in the intervall n,m-1
: sfac \ w -- w ?v | m n -- f 
  bdupeven if 2drop 2 bdup b2/ exit then
  0 locals| flag | 
  do bdup i pnr@ bs/mod 0= 
     if i pnr@ to flag leave then bdrop
  loop flag ;

: sfacset \ b -- b' set
  0                           \ count of the number of elements
  begin pi_plim 1 sfac ?dup 
  while >zst 2 - bnip
  repeat >zst reduce ;

1k bvariable alpha
1k bvariable beta

: bpollard1 \ w -- v | a -- f
  len1 cell = if drop b>s pollard2 s>b true exit then
  s>b bdup alpha b! beta b! bzero true
  begin bdrop
     alpha b@ bdup b* b1+ bover bmod alpha b!
     beta b@ bdup b* b1+ bover bmod
     bdup b* b1+ bover bmod beta b!
     alpha b@ beta b@ |b-|
     bover
     bgcd 
     b2dup= if bdrop 0= exit then
     bone b2dup= bdrop 0=
  until bnip ;

: bpollard2 \ w -- v
  bdup bisprime if exit then
  pi_plim 1 sfac ?dup if bdrop bdrop s>b exit then
  0 begin 1+ dup bpollard1 until drop ;
  
: bfac1 \ w -- v1...vn
  bdup bpollard2
  bone b2dup= bdrop
  if bdrop exit
  then btuck b/ recurse ;

: bfac bfac1 bdrop ;
  
: bfac# \ w -- v1...vn | -- n
  bdepth 1- bfac bdepth swap - ;

: bsfactors \ w -- v1 ... vn set
  sfacset bfac ;

\ -------------------------

[defined] sp0 0= [if]
s0 constant sp0
r0 constant rp0
[then]

: new-data-stack \ u -- 
  dup aligned allocate throw + dup sp0 ! sp! ; 

100000 cells new-data-stack
100001 cells allocate throw 100000 cells + align rp0 ! q

\ testing for small (fast) single number divisors
\ of big number w in the intervall n,m-1
: sfac \ w -- w ?v | m n -- f 
  bdupeven if 2drop 2 bdup b2/ exit then
  0 locals| flag | 
  do bdup i pnr@ bs/mod 0= 
     if i pnr@ to flag leave then bdrop
  loop flag ;

: sfacset \ b -- b' set
  0                           \ count of the number of elements
  begin pi_plim 1 sfac ?dup 
  while >zst 2 - bnip
  repeat 1- >zst ;
  \ list of single factors, set, and the resting big number b'

1k bvariable alpha
1k bvariable beta

: bpollard1 \ w -- v | a -- f
  len1 cell = if drop b>s pollard2 s>b true exit then
  s>b bdup alpha b! beta b! bzero true
  begin bdrop
     alpha b@ bdup b* b1+ bover bmod alpha b!
     beta b@ bdup b* b1+ bover bmod
     bdup b* b1+ bover bmod beta b!
     alpha b@ beta b@ |b-|
     bover
     bgcd 
     b2dup= if bdrop 0= exit then
     bone b2dup= bdrop 0=
  until bnip ;

: bpollard2 \ w -- v
  bdup bisprime if exit then
  pi_plim 1 sfac ?dup if bdrop bdrop s>b exit then
  0 begin 1+ dup bpollard1 until drop ;
  
: bfac1 \ w -- v1...vn
  bdup bpollard2
  bone b2dup= bdrop
  if bdrop exit
  then btuck b/ recurse ;

: bfac bfac1 bdrop ;
  
: bfac# \ w -- v1...vn | -- n
  bdepth 1- bfac bdepth swap - ;

: bsfactors \ w -- v1 ... vn set
  sfacset bfac ;
\ set is a list of single divisors
\ v1 ... vn is big divisors on stack

: isq  sqr ;             \ is perfect square: n -- flag
: isqf  sqrfree ;        \ is square free: n -- flag
: isem  bigomega 2 = ;   \ is semi prime: n -- flag
: ispp  smallomega 1 = ; \ is prime power: n -- flag

: 2sqs  2sqsum ;         \ square sum: a b -- sum
: 3sqs  3sqsum ;         \ square sum: a b c -- sum
: 4sqs  4sqsum ;         \ square sum: a b c d -- sum

: div  swap mod 0= ;     \ divides: m n -- flag
: z. zet. ;
: cset create-set ;
: fset filter-set ;
: bset build-set ;
: tset transform-set ;

: is-sum-of-two-squares \ n -- flag 
  dup 3 < if drop true exit then
  dup isprime if 3 and 3 <> exit then
  true 0 0 locals| m k flag | 
  primefactors 0 
  do flag
     if dup 3 and 3 =
        if m over = 
           if drop k 1+ to k 
           else to m k odd 1 to k 
              if false to flag then 
           then 
        else drop k odd 0 to k 
           if false to flag then
        then 
     else drop
     then
  loop flag k odd 0= and ;

: 2sqrs  is-sum-of-two-squares ;

: is-sum-of-three-squares \ n -- flag
  oddpart 7 and 7 <> swap odd 0= 0= or ;

: 3sqrs  is-sum-of-three-squares ;

: squaresum# \ n -- m=1,2,3,4
  dup sqr if drop 1 exit then
  dup is-sum-of-two-squares if drop 2 exit then
  is-sum-of-three-squares if 3 exit else 4 then ;
\ Lagrange's 4 square theorem

: sqs#  squaresum# ;
: primes  primefactors ;
: card  cardinality ;
: \0  { 0 } diff ;

: divz \ u -- set 
  locals| u | 
  0 u sqrtf 1+ 1
  do u 0 i um/mod -rot 0=
     if 2 +
        i >zst 
        swap >zst
     else nip
     then 
  loop 2* negate >zst
  set-sort reduce ;

: psum \ n -- m
  dup isp if exit then
  primefactors 1
  do + loop ; \ sum of all prime factors

: ismp \ n -- flag
  dup isp 0=
  if drop false 
  else 1+ oddpart nip 1 = 
  then ; \ is Mersenne prime

\ -------------------------- 
false [if]
[defined] sp0 0= [if]
s0 constant sp0
r0 constant rp0
[then]

: new-data-stack \ u -- 
  dup aligned allocate throw + dup sp0 ! sp! ; 

100000 cells new-data-stack
100001 cells allocate throw 100000 cells + align rp0 ! q 
[then]
