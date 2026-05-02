import 'package:drift/drift.dart';
import 'package:gym_corpus/core/database/database.dart';

/// Exercises for the Triceps (Tricipiti)
const tricepsExercises = [
  ExercisesCompanion(
    name: Value('Dip alle parallele'),
    targetMuscle: Value('Tricipiti'),
    equipment: Value('Parallele (o Dip station)'),
    focusArea: Value(
      'Tricipiti (tutti i capi), Deltoidi anteriori, Petto (basso)',
    ),
    preparation: Value(
      'Afferra le parallele, sostieniti a braccia tese. Mantieni il busto il più dritto (verticale) possibile. Gambe incrociate o tese indietro.',
    ),
    execution: Value(
      'Scendi piegando i gomiti (tenendoli vicini al corpo, non larghi) finché il gomito non forma circa 90 gradi. Spingi with forza sui tricipiti per tornare su.',
    ),
    tips: Value(
      'Busto dritto = focus tricipiti. Busto inclinato in avanti = focus petto. Non scendere eccessivamente per proteggere le spalle.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Panca piana presa stretta'),
    targetMuscle: Value('Tricipiti'),
    equipment: Value('Bilanciere, Panca piana, Rack'),
    focusArea: Value(
      'Tricipiti (capo mediale e laterale), Petto (interno), Deltoidi ant.',
    ),
    preparation: Value(
      'Sdraiato su panca piana. Afferra il bilanciere with una presa stretta (larghezza spalle o appena dentro). Stacca dal rack.',
    ),
    execution: Value(
      'Abbassa il bilanciere verso la parte bassa del petto, tenendo i gomiti stretti lungo i fianchi (non larghi). Spingi with forza estendendo i tricipiti.',
    ),
    tips: Value(
      'Non usare una presa troppo stretta (rischio polsi). È un costruttore di massa fondamentale per i tricipiti.',
    ),
  ),
  ExercisesCompanion(
    name: Value('French Press with bilanciere'),
    targetMuscle: Value('Tricipiti'),
    equipment: Value('Bilanciere EZ (o dritto), Panca piana'),
    focusArea: Value('Tricipite (capo lungo e mediale)'),
    preparation: Value(
      'Sdraiato su panca piana. Afferra il bilanciere (presa prona) e portalo sopra il petto a braccia tese.',
    ),
    execution: Value(
      "Mantieni i gomiti fermi (puntati al soffitto). Fletti solo i gomiti, abbassando il bilanciere verso la fronte ('spacca-cranio') o appena oltre la testa (per più stretch). Estendi tornando su.",
    ),
    tips: Value(
      'Il bilanciere EZ è più confortevole per i polsi. Non far allargare i gomiti.',
    ),
  ),
  ExercisesCompanion(
    name: Value('French Press with manubri'),
    targetMuscle: Value('Tricipiti'),
    equipment: Value('Manubri, Panca piana'),
    focusArea: Value('Tricipite (tutti i capi, specialmente capo lungo)'),
    preparation: Value(
      'Sdraiato su panca piana. Tieni i manubri sopra il petto. Presa neutra (palmi che si fronteggiano) è la più comune.',
    ),
    execution: Value(
      'Abbassa i manubri ai lati della testa (verso le orecchie/spalle), mantenendo i gomiti fermi. Estendi per tornare su.',
    ),
    tips: Value(
      'I manubri permettono un ROM più naturale e un allungamento maggiore rispetto al bilanciere.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Overhead Extension with manubrio singolo'),
    targetMuscle: Value('Tricipiti'),
    equipment: Value('Manubrio (singolo), Panca (with schienale)'),
    focusArea: Value('Tricipite (focus capo lungo, allungamento)'),
    preparation: Value(
      "Seduto su panca, schiena dritta. Afferra un manubrio with entrambe le mani (presa 'a coppa' o 'diamante') e portalo dietro la testa. Gomiti puntati in alto.",
    ),
    execution: Value(
      'Estendi le braccia spingendo il manubrio verso il soffitto. Scendi lentamente tornando in posizione di massimo allungamento.',
    ),
    tips: Value(
      'Massimo stretch per il capo lungo del tricipite. Tieni i gomiti stretti (non larghi).',
    ),
  ),
  ExercisesCompanion(
    name: Value('Overhead Extension with bilanciere'),
    targetMuscle: Value('Tricipiti'),
    equipment: Value('Bilanciere (EZ consigliato), Panca (seduto)'),
    focusArea: Value('Tricipite (focus capo lungo)'),
    preparation: Value(
      'Seduto. Afferra il bilanciere EZ e portalo dietro la testa.',
    ),
    execution: Value(
      "Estendi le braccia spingendo il bilanciere verso l'alto. Scendi controllato.",
    ),
    tips: Value(
      'Simile al manubrio singolo ma permette di usare più carico.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Overhead Extension ai cavi'),
    targetMuscle: Value('Tricipiti'),
    equipment: Value('Cavo (Ercolina), Corda'),
    focusArea: Value('Tricipite (capo lungo, tensione costante)'),
    preparation: Value(
      'Posiziona la carrucola in basso. Afferra la corda. Dài le spalle alla macchina e fai un passo avanti. Porta la corda dietro la testa (gomiti flessi).',
    ),
    execution: Value(
      'Estendi le braccia in alto e in avanti (sopra la testa), aprendo la corda in cima. Ritorna controllato in posizione di stretch.',
    ),
    tips: Value(
      'Combina i benefici dello stretch (overhead) with la tensione costante del cavo.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Pushdown ai cavi (Con barra dritta)'),
    targetMuscle: Value('Tricipiti'),
    equipment: Value('Cavo (Ercolina), Barra (dritto o V-bar)'),
    focusArea: Value('Tricipite (focus capo laterale e mediale)'),
    preparation: Value(
      'Posiziona la carrucola in alto. Afferra la barra (presa prona). Gomiti fissi ai fianchi.',
    ),
    execution: Value(
      "Spingi la barra verso il basso fino alla completa estensione delle braccia. Contrai il tricipite. Ritorna lentamente (controlla l'eccentrica) fino a 90 gradi.",
    ),
    tips: Value(
      'Esercizio di isolamento fondamentale. Non usare il peso del corpo; mantieni il busto fermo e i gomiti bloccati ai fianchi.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Pushdown ai cavi (Con corda)'),
    targetMuscle: Value('Tricipiti'),
    equipment: Value('Cavo (Ercolina), Corda'),
    focusArea: Value('Tricipite (capo laterale, ROM completo)'),
    preparation: Value(
      'Posiziona la carrucola in alto. Afferra la corda (presa neutra). Gomiti ai fianchi.',
    ),
    execution: Value(
      'Spingi la corda verso il basso. Alla fine del movemento, apri (allarga) le mani per massimizzare la contrazione del capo laterale. Ritorna controllato.',
    ),
    tips: Value(
      'La corda permette un ROM leggermente maggiore e una contrazione di picco più intensa.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Pushdown ai cavi (Presa inversa)'),
    targetMuscle: Value('Tricipiti'),
    equipment: Value('Cavo (Ercolina), Maniglia (singola)'),
    focusArea: Value('Tricipite (focus capo mediale)'),
    preparation: Value(
      "Carrucola in alto. Afferra una maniglia singola with presa supina (palmo verso l'alto). Gomito fisso al fianco.",
    ),
    execution: Value(
      'Spingi verso il basso estendendo il braccio. Concentrati sulla contrazione del capo mediale (vicino al gomito). Ritorna lentamente.',
    ),
    tips: Value(
      'Esercizio di fino, ottimo per isolare il capo mediale, spesso trascurato.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Kickback with manubri'),
    targetMuscle: Value('Tricipiti'),
    equipment: Value('Manubri, Panca (per appoggio)'),
    focusArea: Value('Tricipite (isolamento, contrazione di picco)'),
    preparation: Value(
      "Appoggia un ginocchio e una mano sulla panca (busto parallelo a terra). Nell'altra mano tieni il manubrio, solleva il gomito fino all'altezza della schiena e tienilo bloccato lì.",
    ),
    execution: Value(
      "Estendi l'avambraccio all'indietro fino a completa estensione. Contrai forte in cima (picco). Ritorna lentamente.",
    ),
    tips: Value(
      "Non far 'cadere' il gomito. Il movemento è solo dell'avambraccio. Usa pesi leggeri, è un esercizio di contrazione.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Kickback ai cavi '),
    targetMuscle: Value('Tricipiti'),
    equipment: Value('Cavo (Ercolina), Maniglia (o senza)'),
    focusArea: Value('Tricipite (tensione costante, contrazione picco)'),
    preparation: Value(
      'Posiziona la carrucola in basso. Piegati in avanti (busto 45-90°). Afferra il cavo. Porta il gomito alto e bloccalo.',
    ),
    execution: Value(
      "Estendi il braccio all'indietro. Il cavo offre tensione costante anche in basso, a differenza del manubrio.",
    ),
    tips: Value('Ottima alternativa ai manubri.'),
  ),
  ExercisesCompanion(
    name: Value('Diamond Push-ups'),
    targetMuscle: Value('Tricipiti'),
    equipment: Value('Corpo libero, Tappetino'),
    isBodyweight: Value(true),
    focusArea: Value('Tricipiti, Petto (interno), Deltoidi anteriori'),
    preparation: Value(
      "Posizione di plank. Avvicina le mani sotto lo sterno, unendo pollici e indici a formare un 'diamante'.",
    ),
    execution: Value(
      'Abbassa il corpo controllando il movemento, tenendo i gomiti stretti lungo i fianchi. Spingi with forza sui tricipiti per tornare su.',
    ),
    tips: Value(
      'Molto intenso per i tricipiti. Se troppo difficile, inizia with le ginocchia a terra.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Dip tra panche '),
    targetMuscle: Value('Tricipiti'),
    equipment: Value('Due Panche (o una panca e un rialzo)'),
    focusArea: Value('Tricipiti'),
    preparation: Value(
      "Posiziona le mani (palmi) sul bordo di una panca, dita avanti. Appoggia i talloni sull'altra panca (o a terra per facilitare).",
    ),
    execution: Value(
      'Abbassa il bacino piegando i gomiti (che puntano indietro) finché non sono a 90°. Spingi sui tricipiti per tornare su.',
    ),
    tips: Value(
      "ATTENZIONE: Non scendere troppo in basso (oltre i 90°) per non stressare eccessivamente l'articolazione della spalla.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Triceps Extension (Macchina)'),
    targetMuscle: Value('Tricipiti'),
    equipment: Value('Macchinario (Triceps Extension Machine)'),
    focusArea: Value('Tricipiti (isolamento)'),
    preparation: Value(
      'Siediti alla macchina, regola il sedile. Appoggia i gomiti sul pad e afferra le impugnature.',
    ),
    execution: Value(
      'Spingi le leve verso il basso (o in avanti, a seconda della macchina) estendendo completamente i tricipiti. Ritorna controllato.',
    ),
    tips: Value('Movemento guidato e sicuro per isolare i tricipiti.'),
  ),
  ExercisesCompanion(
    name: Value('Tate Press'),
    targetMuscle: Value('Tricipiti'),
    equipment: Value('Manubri, Panca piana'),
    focusArea: Value('Tricipiti, Petto'),
    preparation: Value(
      'Sdraiato su panca piana, manubri sopra il petto (presa prona, come in panca).',
    ),
    execution: Value(
      "Abbassa i manubri verso il centro del petto, facendo \"cadere\" i gomiti larghi (come un'alzata posteriore al contrario). Spingi tornando su.",
    ),
    tips: Value(
      'Movemento ibrido, non molto comune ma efficace per uno stimolo diverso.',
    ),
  ),
  ExercisesCompanion(
    name: Value('JM Press'),
    targetMuscle: Value('Tricipiti'),
    equipment: Value('Bilanciere (dritto o EZ), Panca piana'),
    focusArea: Value('Tricipiti (massa), Gomiti'),
    preparation: Value(
      'Sdraiato su panca. Presa stretta. È un ibrido tra panca stretta e French Press.',
    ),
    execution: Value(
      'Abbassa il bilanciere in modo controllato verso la gola/petto alto, piegando i gomiti (come un French Press) ma anche muovendo leggermente le spalle (come una Panca Stretta).',
    ),
    tips: Value(
      'Movemento avanzato reso popolare dai powerlifter. Usa cautela.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Floor Press'),
    targetMuscle: Value('Tricipiti'),
    equipment: Value('Bilanciere (o Manubri), Pavimento'),
    focusArea: Value('Tricipiti (lockout), Petto'),
    preparation: Value('Sdraiato sul pavimento. Presa stretta sul bilanciere.'),
    execution: Value(
      'Abbassa il bilanciere finché i tricipiti non toccano terra. Fai una pausa (dead-stop) e spingi with forza estendendo i tricipiti.',
    ),
    tips: Value(
      "Il ROM ridotto elimina l'aiuto delle gambe e si concentra sulla parte finale (lockout) della spinta, dominata dai tricipiti.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Estensioni su panca '),
    targetMuscle: Value('Tricipiti'),
    equipment: Value('Panca, Corpo libero'),
    isBodyweight: Value(true),
    focusArea: Value('Tricipiti'),
    preparation: Value(
      'Posiziona le mani sul bordo di una panca (presa larghezza spalle). Corpo in posizione plank (piedi a terra indietro).',
    ),
    execution: Value(
      'Piega solo i gomiti, abbassando la testa verso la panca (o sotto il livello della panca). Spingi with i tricipiti per tornare su.',
    ),
    tips: Value(
      "Una sorta di 'Skullcrusher a corpo libero'. Molto impegnativo.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Piegamenti esplosivi'),
    targetMuscle: Value('Tricipiti'),
    equipment: Value('Corpo libero'),
    isBodyweight: Value(true),
    focusArea: Value('Tricipiti (potenza, fibre veloci), Petto'),
    preparation: Value('Posizione di push-up (presa media o stretta).'),
    execution: Value(
      "Scendi velocemente e spingi via il pavimento with la massima forza possibile, cercando di staccare le mani da terra ('clap push-up' è una variante). Atterra morbidamente e ripeti.",
    ),
    tips: Value(
      'Sviluppa la potenza e la forza esplosiva dei tricipiti e del petto.',
    ),
  ),
];
