Use CA6336_Snap
Go

IF object_id('tempdb..#TNsToExcludeFromManualProcess') is not null
	drop table #TNsToExcludeFromManualProcess

create table #TNsToExcludeFromManualProcess (Tracking_Number int)


--had to get rid of whitespace, tabs, newlines.  Fun stuff.
--Parse out the string so we can check existence in the remediation sent table.
declare @String varchar(max) =              
           (select   Replace(        
                        Replace(
                            Replace(
                                 Replace( (select   '1981,4583
                                                        ,3906
                                                   
                                                            ,66812,110644,259593
                                              
                                                            ,263925
                                                 
                                                            ,184579,74050
                                          
                                                            ,2371,2978,28467,218225
                                                    
                                                            ,105615
                                                      
                                                            ,199422
                                                          
                                                            ,12675,14474,17091,18151,23230,25613,35972,38975,39883,69776,93387,102572,140146,173698,253179,266635,281681,285706
                                                           
                                                            ,205282,24570
                                                           
                                                            ,18387,22870,24067,24891,28484,40134,40196,186716
                                                            
                                                            ,21872,24722,33314,40646,81374,99878,130280,165585,169555,182390,220210,292990
                                                          
                                                            ,19122,37276,46966,49346,56065,93673,100779,114068,116629,120368,123682,149278,156876,163935,168574,190640,197191,197994,215402,215719,238806,244741,246142,255157,259817,268181,276610,276819,291219
                                                      
                                                            ,947,1184,1879,9285,11476,21601,22158,24807,30247,49353,82616,89019,98097,128406,146556,156209,162754,167925,176072,181241,197149,222014,273693,274203
                                                       
                                                            ,611,793,1721,2620,2747,3341,3857,4014,4294,4425,5169,5885,5953,5954,7258,7472,7970,8729,9323,9533,9820,10121,10720,10919,11223,11430,11522,12680,13913,14412,15572,15625,15670,15928,16159,17098,17639,18178,19239,19683,20531,20798,21219,22243,22833,23328,23343,24138,24978,24987,25232,25400,25408,25826,26805,26947,28909,29020,29137,30313,31310,31467,31961,32939,33374,33619,34937,36700,38092,38108,38285,38361,38655,38819,38978,40384,40393,40575,40967,41245,41304,41365,41649,43288,44510,44938,46060,54201,54343,57869,57880,58459,58879,59746,63186,66630,70956,71845,72256,75127,76176,77263,77376,77641,78943,79249,80575,81591,81799,82917,83460,83597,84191,84666,84864,85093,85447,86906,87263,91853,93566,93862,95626,97573,98250,99085,99520,99546,100306,101056,103683,103855,105955,106018,107345,108117,108238,109184,111583,111877,115416,119665,120027,120475,120584,120853,121097,121645,122111,122681,123102,125891,126975,127966,128228,128557,129020,129366,130853,131662,134540,135412,139974,140472,144577,144848,145372,146242,148730,151827,155091,155648,156304,157096,158458,160658,162704,163065,166347,167011,167252,170502,171153,171189,171628,178187,178454,180105,181315,182509,183733,184094,185680,187864,189002,189024,190027,190953,197453,197550,199406,199428,199442,200503,200736,201161,202729,203002,203453,204628,205297,206809,213203,217502,219411,219809,223906,226264,227007,228725,229645,230576,230941,235905,236131,237788,238003,242473,243537,243839,245667,245672,250943,251183,253182,253551,253826,254221,254290,255483,255990,256133,260646,264205,264443,265649,266300,266558,266986,267862,268216,270204,270635,274475,276516,277360,278742,282617,289448,290216,292125,293013,293532,294267
                                                          
                                                            ,903,1891,17910,26176,29150,31677,31791,45692,46409,48007,62567,62808,63180,68141,86879,87685,89830,95230,98615,105203,116966,128798,128926,129010,137060,139810,148144,153468,163279,166053,169310,172328,173896,200044,219042,224909,231289,235283,253702,263126,267161,268682,289497,292814
                                                      
                                                            ,1562,2667,7585,8407,31451,39882,43492,77241,99652,117232,119159,172582,183120,183418,241404
                                                          
                                                            ,109896,105495,159810,101283,139115,242,3021,18246,20963,26496,27315,27739,36170,46296,49706,50955,52405,56861,58192,60143,61075,61466,61983,70390,74755,74988,76147,76992,84479,85233,86411,88448,91846,93265,94191,105984,107659,110497,115079,115130,120133,127666,127992,129269,132690,134177,134924,140302,142615,143012,143363,162003,165000,165009,167384,167787,172279,177258,179161,182347,186003,188737,190837,191578,195810,198668,202780,210525,216562,226120,230534,232738,238570,242460,244930,262165,263103,266466,268676,270649,279140,279192,280876,289520
                                                           
                                                            ,40997
                                                          
                                                            ,270551,222493
                                                            
                                                            ,25951
                                                           
                                                            ,134291, 293285, 258550, 261332, 38792
                                                            
                                                            ,92810,130324,170158,273638,282822,245931,251372,183837,282943,227046,139614,179317,174858
                                                           
                                                            ,292061,280161,109772,6917,6438,48334
                                                             
                                                            ,199604,223320,128125,46218,194569,180938,194569,46778,126535,135453,275577,256484,25391,291976,95139,131267,108993,250215,117849,151334,192234,156061,164690,237331,120872,187449,120877,33337,172521,105507,118397,247672,99441,43652,121365,48794,172521,27297,69878,187449,154613,292612,134442
                                                          
                                                           ,199604,223320,128125,46218,194569,180938,194569,46778,126535,135453,275577,256484,25391,291976,95139,131267,108993,250215,117849,151334,192234,156061,164690,237331,120872,187449,120877,33337,172521,105507,118397,247672,99441,43652,121365,48794,172521,27297,69878,187449,154613,292612,134442
                                                          
                                                           ,7265,41491,47121,80116,73758,82683,98686,103541,154058,170501,203097,167475,214627,203528,239993,234177,262952,262355,262328,27138,85558,121761,164800,187298,185606,196216,223276,247358,254284,277349,11143,84486,96034,98269,105205,115597,116344,121957,125833,135452,173592,274536,35474,79705,74605,60951,92506,110863,106827,130497,128871,182748,180590,222011,236527,267641,256813,259407,288349,10286,22752,27505,65992,79569,84616,84920,107019,131925,139646,134896,132827,161859,186096,218459,215365,291847,280849,13877,47312,67463,67399,80786,77694,83885,108309,108270,110668,125271,150269,150271,184155,198132,215172,212641,243606,275975,12038,6707,82022,121109,141573
                                                         
                                                           ,167757,4405,40212,42090,42266,52130,58364,112348,114598,164986,199840,206246,228485,248686,278541,158823,288746
                                                           
                                                            ,43034,72249,121578,171426,4884,91559,99612,245160
                                                
                                                            ,72644,246419,253916
                                                      
                                                            ,3430,5039,5905,7535,10517,15938,16052,18394,19443,20265,21209,22793,25936,27522,30561,31183,32275,34883,36905,39044,43744,43745,44055,45215,46119,49561,51170,57337,60385,60811,63515,64722,68544,70553,72252,76784,81634,82800,84521,84895,88482,88960,89303,89315,98391,100170,102580,111925,112048,113497,115329,121121,122170,122732,127765,129050,129723,130235,132563,134660,134683,138921,139085,139943,142452,142485,142661,145485,146697,149412,152025,153112,162404,164879,165561,167732,168557,169719,170700,171209,175617,177542,183625,183919,185569,187492,187971,189281,189908,193309,197118,197209,200524,202519,204723,206491,206845,207677,210077,210080,210744,220162,224159,224685,226658,228761,230013,231826,234281,234452,234766,239196,240147,241029,241787,244268,245785,247144,247271,247383,249017,249872,256452,257204,258999,264399,265335,267678,270299,271504,273519,273999,274866,275672,276256,276805,277791,277875,281135,281913,288367,288991,289358,155769,269219,88699,174423,28677,154832,51359,79279,72612,93345,120346
                                                     
                                                            ,4452,8101,12303,15024,18471,19625,21293,25603,30081,30261,31446,35545,49204,51226,51352,54035,54851,61748,63572,64031,71978,76714,80877,82970,83564,87354,87626,90482,94451,99929,100082,103165,103472,105276,107368,110750,121440,126259,135567,150426,152369,152788,155068,155559,159817,160095,163569,168813,173131,173471,181742,189881,195449,201469,204926,205463,205933,207146,207623,214189,216374,216529,222078,224394,227213,230951,233064,234725,238447,240748,242293,257052,266051,267345,273932,276896,277532,279279,287461,288515,293455,154733,117417,229047,49227,152224,23361,118632,62069,21051
                                                      
                                                            ,7813,18273,23837,28720,31293,32463,36490,51399,55527,89987,94599,94631,120986,129394,140423,149267,154231,158877,158925,159277,160161,166044,177443,180100,183343,191616,194891,196178,196262,208161,213122,230288,238090,240347,240900,242085,246848,247151,247249,248119,270731,273120,274825,279389,288396,289516,950,2239,4444,11414,11563,17679,38854,43884,46342,47577,47846,54980,62387,17761,27771,29791,33487,42534,66877,86581,87767,88830,92999,93967,95030,104924,68504,71194,72131,79217,79933,84813,85668,96798,100105,100541,105134,106642,112708,115014,118588,22922,28061,28395,36569,42980,66653,68423,69600,70865,73017,78249,80991,84783,123787,127766,129738,129986,135535,138058,138509,146601,149275,158581,185305,196419,201014,203758,218797,240392,252808,254878,276739,276806,281319,285980,289641,293803,89708,92039,93557,97735,118375,118768,119565,124602,130107,137272,139299,140814,151758,108557,111531,114984,138630,147781,154701,159747,190624,193450,196985,197726,226129,226404,244345,251499,271689,287156,163301,186013,187006,202859,204363,205906,207103,212140,212860,217240,220939,222604,223606,229065,237655,248685,250637,256905,257414,260267,260333,261535,290104,84942,248116,122315,202565,75348,42081,237289,164600,131169,242569,260815,226664,237263,199908,74708,135343,36033,155152
                                                     
                                                            ,23674,38071,43939,44684,54785,55078,58672,59456,67246,75650,89272,94409,100091,101597,103912,104748,107874,110589,114481,116105,121192,123725,3430,34289,52523,53923,54266,55088,71650,76226,82117,87022,87485,90643,95473,12482,23695,39440,45725,46191,49400,54947,57656,59477,61217,62602,64172,65979,97797,103329,104045,107864,109527,115386,130603,139511,149753,158661,168364,168791,171704,141255,141446,145060,159457,161954,165857,166961,173695,177162,186622,191177,197102,198999,70508,80301,80518,85650,88806,89961,107007,110618,119509,124890,143824,147253,149125,149760,150947,155489,156910,178485,186393,191859,196337,199044,201082,204189,205427,205478,174044,179701,181334,185392,186080,189145,193548,199082,201688,208765,209469,211246,223346,232315,4216,19495,21480,23623,31391,33867,35035,46983,51648,51683,61523,68125,82382,82649,92325,96556,101219,102369,104158,104375,106699,109107,111577,127019,131550,131632,207268,208268,213114,214502,230395,232635,236062,236430,240306,240792,243918,254696,257787,131917,149748,151456,152207,156435,157372,159475,166511,170622,171041,172377,182723,185898,193202,197146,202877,202979,203850,205353,207141,209096,209246,212188,216367,228448,231173,199717,203316,206719,214875,218753,222184,223817,226625,228770,233284,241890,244850,245766,248783,252095,253354,259120,261151,262880,263016,287943,289756,294159,237574,237875,238693,242135,242623,243338,250843,253469,271766,277351,279154,279571,288346,233810,234119,235934,243738,246310,246410,248559,254927,262238,264837,265380,266039,270369,265359,269787,270339,275437,276923,277007,278544,279883,283408,293955,149709,163577,108021,100623,253401,54100,161736,165110,235477,153823,253431,220027,93477,239345,35785,34759,15749,99020,291348,93100,126547,87593,284811,36491,148732,265475,70738,193034,38071,61523,51648,62602,21480,53923,49400,89272,44684,107874,148732,82649,124890,87022,88806,173695,179701,46983,126547,59456,70738,104748,201082,275437,193034,202877,250843,223346,218753,205353,185898,213114,214502,114481,278544,110589,277007,291348,230395,270369,207268,287943,279571,263016,253354,174044,186393,283408,194038,193850,282448,256083
                                                     
                                                            ,15,2919,3180,3497,5418,8867,13082,13827,22246,30574,32330,36189,43896,46929,47378,49518,53545,64139,64554,66281,68085,71794,72016,74358,74751,83985,85214,94283,95675,97726,97822,101331,109398,112341,113206,113316,113367,124300,124701,124855,128221,131518,133058,133519,141060,203590,250703,270131,271293,276195,277666,281161,285017,286101,290924,291371,291475,292513,51613,129662,94934,273755,1537,247520,16914,110785,70330,78302
                                                         
                                                            ,26449,30521,31222,35522,36194,49309,50445,51924,74101,76983,78862,80927,83750,84435,85045,89121,89223,89660,92816,94044,97245,97757,104680,105501,107292,113401,116937,119719,123327,128392,134165,136880,137527,140198,142531,142717,147072,149491,153932,163366,175676,177323,186109,189645,190969,191209,195154,202461,202700,209674,211639,213528,215605,218784,218964,220309,220506,220510,225780,228638,230465,230999,234424,236099,237732,240193,240894,258241,289210,291079,291213,84825,186862,168407,98996,240546,190956,102739,81382,240603,193979
                                                        
                                                            ,287,14485,22676,23580,30039,34924,47362,107839,119246,133526,152198,172146,173822,188444,210411,211082,215468,231136,250738,251907,261462,264824,266750,277512,139350,15799,282166,264904,17303
                                                         
                                                            ,835,2390,3522,5304,7458,8413,9376,9706,10863,13253,16420,17634,20954,22076,22696,23283,23607,24135,24878,27577,28210,30003,30765,30959,31101,35490,35731,36023,36563,36793,39783,40417,41928,44080,44876,44957,45259,45372,45671,45822,46014,47382,47472,47558,47567,48219,48221,48535,49182,50288,50438,53607,54450,54636,56511,57977,58465,58848,60162,60407,61020,61458,62136,62420,63262,63453,64727,65084,65425,65485,67257,68420,69778,71316,71374,71444,71504,72322,72671,74010,74093,74392,76205,76404,76853,77921,77991,78812,79171,80423,80521,81721,81807,83218,83435,83669,84113,84175,84356,85529,85579,86010,86732,87466,88014,88604,88976,89185,90247,92705,93879,94384,94391,94491,95200,95848,95983,100267,101649,103550,105293,107041,112028,112839,113452,115047,115152,117818,118802,119810,120522,120630,121314,122180,122363,123680,126815,128836,130270,134434,135203,135551,137280,138431,138722,139324,142710,143898,145288,146618,147017,148888,150007,150283,150672,151698,153256,153621,154649,154763,155738,156126,156829,156862,159069,159378,159520,159657,159776,160205,160375,161412,162869,164243,165078,165856,166023,167143,167721,168957,169186,169479,169626,169781,172542,172950,173187,173206,173216,173485,173649,175393,176795,176861,177240,177331,177935,179025,179600,179660,180079,180450,180879,181280,181450,181702,181753,182249,183224,184677,184743,184794,184857,185024,185265,187804,189078,190016,190995,191852,195443,196201,196566,197128,198191,198351,202092,202182,202217,202508,202856,205943,206785,206874,207620,208771,211324,211633,212029,212213,212232,212374,212536,214676,215576,216629,217505,218400,221052,221816,221981,224763,225641,225919,226084,226572,227173,227798,227879,228657,228795,228993,229842,229904,231300,231346,232834,233818,234104,235225,236762,238441,239342,242026,242126,242313,242522,243565,244284,244333,244380,244893,245481,245524,245637,247427,248595,248999,249088,249146,249338,251210,251238,251985,253440,253683,255029,255585,256910,258625,258912,259412,259596,260407,261643,261941,262984,263382,263738,264787,265126,265197,265265,266148,266249,266709,267000,267918,268148,269015,270160,271427,271774,272620,274189,275061,275526,275605,275618,276893,276930,278710,279268,280136,280173,280197,281073,281179,281293,281340,281699,282304,282329,282381,284179,284532,284840,285476,285735,285974,286346,286801,287608,288934,288988,290762,291314,291884,292176,292530,293920,294016,54833,204645,266919,183511,21471,6057,151284,115333,208233,216827,41292,101602,65537,165725,219200,140818,110236,184671,288246,11191,144978,10797,236037,57727,286560,19869,281129,836,32609,6201,91711,180255,119492
                                                          
                                                            ,186969,235054,147530,236583,291985,288430,66508,189743,243005,31412,94287,143667,238688,13340,269658,18861,135780
                                                       
                                                            ,254225,180698,210083,232705,268447,64685,160952,1640,170141,17205,281487,253584,63285,62199,201622,202308,229287,108627,123254,188264,199312,201335,129759,148727,206792,456,39430,53605,125067,137064,165160,23502,163577,100623,253401,161736,165110,235477,153823,253431,35785,87593,284811,148732,265475,70738,193034,84942,98996
                                                      
                                                            ,266,5112,10294,11363,24113,25200,25316,31583,36882,43350,49151,58641,70208,74035,79999,101776,107123,111337,121563,127278,136772,153469,164382,169864,189936,199177,201817,211896,220419,221905,222323,227941,228857,234507,250035,261380,275521,279080,285548,286933,288052,4651,47585,84473,87111,90519,109822,136881,138939,142662,149582,168486,192098,192633,195644,1357,6394,8341,39893,47481,56205,59431,69979,76354,84767,94761,7106,18229,24568,39946,40035,43947,45083,47682,53155,72457,81619,83623,87285,95414,98515,197849,199119,209045,213592,224570,230954,248086,265834,273239,277886,294429,114976,117957,137865,141466,141673,144115,152512,162297,168697,171939,177946,180813,183780,129422,138950,143153,152336,156964,157459,159674,195565,196474,201804,218727,218743,230359,192113,206912,218633,230385,269148,284174,292219,239676,244881,245367,248357,266257,291332,16838,205205,246903,187290,265826,107273,143554,216835,135809,70277,243061,48696,59690,75259,185482,139898,98996
                                                     
                                                            ,266,8410,18450,41111,41309,51859,56970,61271,66763,82861,97714,113395,126127,127788,143960,146253,158363,189631,196116,198716,225497,229407,235690,241347,249899,253325,270624,281926,292170,192021,290098,225156,71279,116853
                                                            
                                                            ,73520,252417,274297,286729,83469,175805,180335,226745,24717,58776,79314,185724,232921,14500,79026,87384,116348,220389,245416,276043,28254,92361,8962,59513,266,8410,18450,41111,41309,51859,56970,61271,66763,82861,97714,113395,126127,127788,143960,146253,158363,189631,196116,198716,225497,229407,235690,241347,249899,253325,270624,281926,292170,192021,290098,225156,71279,116853
                                                            
                                                            ,21605,59432,61740,77307,85352,86456,86838,122043,126782,185308,239617,247448,248866,249793,277337,281815,283151,40958,109176,110271,122035,154875,178198,179400,210686,261853,19217,30650,36783,81355,133097,133631,156158,164079,192458,202253,232017,289608,16116,19257,29053,93010,116376,124984,132287,136364,170590,192650,193438,195776,200739,201943,206857,273307,20235,61879,199669,209689,115728,191295,73405,40780,54097,109355,223056
                                                        
                                                            ,7995,10278,47326,51129,59201,68359,185785,186975,190089,192127,197124,225545,227823,245883,255137,255958,257095,277075,279594,283374,288533,45933
                                                     
                                                            ,17475,23257,24284,31813,40078,42520,44097,44540,47566,54584,57074,59500,66107,1041,20745,27968,42039,44964,51515,52950,90205,90488,8075,27904,33913,34381,40999,60117,62725,65179,70263,78892,84733,85780,87448,88009,93459,110355,110462,111732,119063,121601,141882,2369,17110,30914,65844,68184,72398,93822,105438,172866,187885,203568,203845,223692,227300,231219,231930,247422,253054,270943,280589,106338,120945,124689,127865,143991,147601,151932,162644,166856,100533,144818,160815,231057,236654,247401,249826,253569,278788,66911,67454,68181,73004,99351,106969,121604,125746,133018,137848,140756,282831,180692,184589,187729,190719,201350,208403,216559,218246,218746,220521,152572,161219,163132,174198,174230,180523,180646,191955,203485,210853,212868,214881,216462,236257,237418,248984,261679,266816,268690,269667,277539,286572,254363,259310,261012,268234,269235,270322,270740,276756,15767,27163,73007,6144,93977,97362,105557,38404,87052,102210,193497,127814,137476,178470,201891,212087,266769,127207,129122,179421,200833,220199,252489,260863,280435,251922,56535,99773,21848,134343,113826,11437,200313,246972,59768,34188,87200,267197,39006,96292,120617,6645,118114,249900,70435,124858,102905
                                                           
                                                            ,61047,165620,34244,78818,110631,127804,251415,41020,98058,228983,236522,133101,151651,156349,213394,274973,26138,110469,252305,189639,88720,248642,175867,127804
                                                         
                                                            ,35645
                                                           
                                                            ,2361,29184,41743,47606,55621,58100,85134,87463,122751,143788,154226,159766,172360,186697,197259,208198,215334,223986,225585,235936,237992,259167,261539,268648,273076,282277,286673,19842,232864,106697
                                                          
                                                            ,66122,96105,97876,105980,107549,114285,144601,148980,156251,171460,208043,226008,246784,7503,11461,78879,98449,101191,118321,139480,146517,163479,229661,250770,288856,23417,44641,63250,88304,170362,267776,2031,53373,72936,98147,134781,141040,162514,252964,260257,261727,156835,90912,10975,219604,252258,275765,57475,63278,268717,76560,192788,21029,168842,82574,233861,109371,182801,234744,105492,232397,13186,137410
                                                          
                                                            ,160801,194345,112571,277607,2820,32877,68523,122319,240354,40977,37858,269320,242643
                                                           
                                                            ,401,7372,88785,97046,153758,155454,169121,192077,227378,14100,8051
                                                           
                                                            ,75067,199848,196514,221275,51112,131500,40558,215538,257586,200805,250257
                                                        
                                                            ,24276,33195,50724,83395,89702,91925,96896,148702,151034,176477,178143,252254,261761,283715,173009,15245
                                                          
                                                            ,104940,138591,230984,286386,193269,22872,111949,234161
                                                        
                                                            ,43454,44803,56689,87637,94112,100327,132673,134517,190483,223910,235431,240728,241640,245159,246829,254503,258653,269975
                                                         
                                                            ,12806,56094,80124,82133,153560,181154,188571,269429,277416,21059,56480,89413,90483,98123,40046,91947,97904,189688,206318,207143,209360,215301,259387,113229,130209,137295,175158,185109,21891,27691,27709,47145,47579,72161,232314,260381,283745,105656,121529,139548,156241,162360,163313,194298,226802,227489,262249,267128,274331,280736,294035,10336,14879,29035,36006,128657,142315,159194,160160,163370,173031,182172,185047,224871,226445,231405,275847,287995,8325,14766,24053,58313,96358,98114,29950,36602,58778,68020,70864,72159,84977,120582,156205,206909,220190,267218,284739,125915,126508,128337,129848,132322,145276,159357,4077,25101,55416,78746,104954,212837,218283,222293,225146,233852,244880,292337,293598,146314,169295,249065,274184,288353,145974,17165,271755,72916,116346,222251,129616,182172,96482,6465,211594,233993,66739,29643,172831,180674,112299,39638,2157,77962,24369
                                                          
                                                            ,212272,6072,18056,20330,39515,65937,74745,95717,113501,133254,196296,247282,247517,266486,10012,10641,14742,18988,28964,33283,49606,59800,65355,66075,74206,99978,129733,137021,141224,145909,152781,161251,165363,170202,175300,199591,205248,210778,268731,275599,285459,286086,289244,291893,14268,31814,39284,53960,85487,101779,105125,112245,113581,133626,152803,159196,162647,183973,13986,47594,61264,87488,110984,115680,126796,126881,129735,150308,150493,164300,179022,206014,213773,217765,238039,292044,212179,226554,265024,286065,159478,76790
                                                          
                                                            ,251608,106,49778,51195,83603,103505,108453,111413,193686,195510,210768,227278,228283,228766,31070,52996,55670,79931,92265,103693,110038,136683,159079,219227,65776,72258,95013,97805,116837,124779,133553,146144,167779,172959,175792,110786,180527,212899,237165,238718,256887,261654,282553,289071,273005,290218,292209,206810,209736,211147,219519,234129,235181,243485,250821,270150,114631,103383,288248,146890,156962,89455,281472,263372,247875,257792,262938,264897,2815,5582,5860,8395,9022,10742,12859,13127,21358,21866,22476,25972,26626,29539,31097,35400,37906,38063,38676,38808,39530,39797,40195,41939,43532,43973,44323,44934,46349,48428,55363,57729,59081,60742,61043,61115,63646,63809,64460,65671,65729,65913,66575,69502,70376,73952,78103,79127,79401,80333,80648,81193,81356,82112,82629,82973,83293,84824,89544,90843,91237,93047,93572,95303,95724,96202,97508,100442,105503,107013,108546,109932,112203,113182,114001,114672,115141,116925,122626,123162,123231,126879,131318,132015,132923,135499,136472,137966,138319,140223,142200,144532,145876,146305,147468,148156,148342,151685,152217,153409,153470,155403,158525,158634,160068,161235,161238,163188,163291,166450,169317,177564,181434,183074,183686,185243,192776,194441,197625,198491,199170,199413,199567,202810,203594,204565,205487,206448,213941,215783,217127,218122,220503,221305,225767,231808,233782,235420,236269,237152,239382,241918,243176,244928,245643,246450,247336,250859,252229,252631,252721,253592,255544,257416,259394,261320,262046,265224,267518,267665,270054,271423,271558,272616,275989,278412,279285,280237,283004,288036,288742,290011,292535,190291,184780,47228,234157,81544,949,275029,262536,234248,42526,149964,58693,109225
                                                        
                                                            ,51652,202597,106607,45685,275656,98742,203861,196862,3019,5059,6086,9710,10441,18059,19320,24904,33978,37520,41441,42627,61438,69801,76053,80340,82678,104070,105949,109443,112487,117960,118651,120907,122322,140577,141433,143135,153783,156739,162137,163293,164211,167085,168028,168800,169523,182452,186630,189011,190949,195897,196517,199280,202865,206818,215174,227826,229698,236709,237161,238088,238456,240537,253248,256933,273470,274179,278532,282669,283135,292238,1296,2457,2668,5669,11149,14200,14741,18187,21411,23824,24939,25278,1026,3884,5386,12139,15882,19811,30106,35204,49960,58984,1035,1654,12263,23513,23629,26153,27241,29430,34961,35144,40140,46559,26241,26782,27793,28156,29456,40563,42369,59465,60360,63311,69836,57821,78361,81319,85281,90462,94709,97498,98518,99754,100856,119542,120112,65019,66438,72139,74192,74462,83870,98108,110458,112379,133591,73235,80023,89145,96147,106911,108340,110139,140853,155118,163953,186547,187576,191525,205013,210829,216813,222163,224542,227307,229340,233198,235974,124456,129804,132562,140516,144763,151062,152133,156662,161374,171001,180461,242242,249971,257977,258986,263214,265640,266676,266699,271506,272313,272658,275121,277395,278413,291033,294091,140790,141227,148329,149416,152274,153893,158540,158975,159762,166781,168065,172243,172814,186669,189057,196763,208008,213223,217771,230587,232926,240213,243673,249256,250175,253050,256912,263145,263529,265098,271334,278336,184036,195601,196737,198273,200631,202017,220920,224278,233189,240742,250868,251872,256670,265042,275137,288170,111165,74238,177953,182715,158517,270178,182540,55619,278705,31091,115308,195555,167134,130255,56836,73037,13426,223569,236391,57949,284889,98267,131430,199957,216018,155967,63959,106554,276836,279752,25835
                                                          
                                                            ,263910,103223,7832,66092,131974,288902,5443,32038,51567,235280,14721,15774,37535,255617,145355,86957,157176
                                                         
                                                            ,182165,89028,100844,148494,162707,186916,200311,274213,173225,180288,202423,43107,160445,182756,205371,256026,261389,27157,171185,172305,232567,280649,73363,170086,280295,82138,286117
                                                   
                                                            ,32219,33825,77945,127996,275078,188486,10444,30331,41762,84030,149573,167305,187879,274933,37812,64018,68314,90335,41788,77904,86776,132853,213274,236386,5716,43497,94753,155162,209467,38255,114896,136731
                                                           
                                                            ,206150
                                                          
                                                            ,25647,29575,31747,50840,51533,57133,59021,74499,2968,5315,34286,45143,48469,64354,80523,83204,87082,93350,11288,21298,24038,33416,42087,42941,47871,67207,73961,85860,101116,107786,112029,120353,156769,244611,258433,259267,266335,291723,115,1285,19034,42279,55383,83209,92720,123836,154070,99448,148893,170710,174097,177198,192581,206478,222238,255501,256816,273862,129158,134720,173267,174655,219981,227644,249150,252660,293347,192493,273917,97326,267059,156596,293582,119285,166152,53722,38068,46913,198442,68740,69982,197185,126636,198587,195
                                                          
                                                            ,171664,37696,251334,87583,258706,159006,26379,39393,53311,87385,185263,74168,198853,250654,38085,163675
                                                        
                                                            ,170659,171573,73774,279642,233299,287086
                                                         
                                                            ,58005,85454,117033,122818,180691,185627,276327,217274,235586,270972,3004,1803,7194,10815,16326,38438,56084,80925,96168,81100,97346,139597,184635,125929,128525,136079,143131,160054,173954,99160,206538,223847,255527,112018,201914,208347,262777,264835,187958,125389,233085,9678
                                                      
                                                            ,32404,44500,64285,81454,83475,88868,113490,21194,34998,44722,54744,60320,76124,18722,20573,9918,15960,106518,121751,145013,183771,193365,259654,272715,286480,123789,129469,139428,165089,184660,201058,204875,235624,252375,260913,273474,47912,81993,180165,182157,70385,40390,154608,94351
                                                           
                                                            ,136171,116641,155277,166040
                                                          
                                                            ,141891,129451,129369,98561,150654,136797,117974,290773,42128,174651,99944,237286,139481,179546,287173,85188,207694
                                                       
                                                            ,123295,43367,187814,215822,27212,72495
                                                            ,37666,286237,109058'), ' ', ''), 
														char(10), ''),
													char(13), ''),
											    char(9), '')
												)	
   declare @separator varchar(1) = ','
   DECLARE @position int
   SET @position = 1
   SET @string = @string + @separator
   WHILE charindex(@separator,@string,@position) <> 0
      BEGIN
         INSERT into #TNsToExcludeFromManualProcess
         SELECT substring(@string, @position, charindex(@separator,@string,@position) - @position)
         SET @position = charindex(@separator,@string,@position) + 1
      END
     
--These tracking Numberes need added.
select exclude.Tracking_Number as TNsThatNeedAddedToSentFile
from #TNsToExcludeFromManualProcess exclude 
where Tracking_Number 
not in (select s.Tracking_nUMBER FROM CA6336.dbo.WellsFargo_RemediationSent s) 
