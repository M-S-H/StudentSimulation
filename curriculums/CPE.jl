# Define Courses
engl110 	= Course("ENGL110", 3, Course[]);
math162 	= Course("MATH162", 4, Course[]);
ece101 	= Course("ECE101", 1, Course[]);
ece131 	= Course("ECE131", 3, Course[]);
phyc160 	= Course("PHYC160", 3, Course[]);

engl120 	= Course("ENGL120", 3, [engl110]);
math163	= Course("MATH163", 4, [math162]);
phyc161	= Course("PHYC161", 3, [phyc160]);
phyc161l	= Course("PHYC161L", 1, [phyc160]);
ece231	= Course("ECE231", 3, [ece131]);

ece203	= Course("ECE203", 3, [ece131, math163]);
ece238l	= Course("ECE238L", 4, [ece131]);
biol110	= Course("BIOL110", 3, Course[]);
biol112l	= Course("BIOL112L", 1, Course[]);
engl219	= Course("ENGL219", 3, [engl120]);
econ105	= Course("ECON105", 3, Course[]);

ece206l	= Course("ECE206L", 2, [ece203, engl120]);
ece213 	= Course("ECE213", 3, [ece203, math163]);
ece300	= Course("ECE300", 4, [math163]);
math264	= Course("MATH264", 4, [math163]);
ece330	= Course("ECE330", 3, [ece231]);

ece321l	= Course("ECE321L", 4, [ece213]);
math327	= Course("MATH327", 3, [math163]);
ece314	= Course("ECE314", 3, [ece213, math264]);
ece340	= Course("ECE340", 3, [ece213, math264]);
span101	= Course("SPAN101", 3, Course[]);

ece335 	= Course("ECE335", 3, [ece330]);
ece331	= Course("ECE331", 3, [ece231, math327, ece340]);
ece344l	= Course("ECE344L", 4, [ece206l, ece238l, ece321l]);
psy105 	= Course("PSY105", 3, Course[]);

ece419	= Course("ECE419", 3, Course[]);
ece437	= Course("ECE437", 3, [ece330]);
ece435	= Course("ECE435", 3, [ece335, ece331]);
ece338	= Course("ECE338", 3, [ece238l]);
clst107	= Course("CLST107", 3, Course[]);

ece420 	= Course("ECE420", 3, [ece419]);
ece440	= Course("ECE440", 3, [ece330, ece340]);
ece438	= Course("ECE438", 3, [ece338, ece344l]);
hist101	= Course("HIST101", 3, Course[]);
arth101	= Course("ARTH101", 3, Course[]);

# Define Terms
t1 = Term([engl110, math162, ece101, ece131, phyc160]);
t2 = Term([engl120, math163, phyc161, phyc161l, ece231]);
t3 = Term([ece203, ece238l, biol110, biol112l, engl219, econ105]);
t4 = Term([ece206l, ece213, ece300, math264, ece330]);
t5 = Term([ece321l, math327, ece314, ece340, span101]);
t6 = Term([ece335, ece331, ece344l, psy105]);
t7 = Term([ece419, ece437, ece435, ece338, clst107]);
t8 = Term([ece420, ece440, ece438, hist101, arth101]);

terms = [t1, t2, t3, t4, t5, t6, t7, t8];