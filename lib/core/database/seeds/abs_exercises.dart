import 'package:drift/drift.dart';
import 'package:gym_corpus/core/database/database.dart';

/// Exercises for the Abs (Addominali)
const absExercises = [
  ExercisesCompanion(
    name: Value('Crunch'),
    targetMuscle: Value('Addominali'),
    equipment: Value('Corpo libero, Tappetino'),
    isBodyweight: Value(true),
    focusArea: Value("Retto dell'addome (focus parte alta)"),
    preparation: Value(
      'Sdraiato supino, ginocchia piegate, piedi a terra. Mani al petto o ai lati della testa (non tirare il collo!).',
    ),
    execution: Value(
      "Solleva spalle e parte alta della schiena da terra, contraendo l'addome. Pensa ad \"accorciare\" lo spazio tra sterno e bacino. La zona lombare rimane a terra. Scendi controllato.",
    ),
    tips: Value(
      'Non tirare la testa with le mani. Il movemento è breve e concentrato. Espira quando sali.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Crunch inverso'),
    targetMuscle: Value('Addominali'),
    equipment: Value('Corpo libero, Tappetino'),
    isBodyweight: Value(true),
    focusArea: Value("Retto dell'addome (focus parte bassa)"),
    preparation: Value(
      'Sdraiato supino, braccia lungo i fianchi (palmi a terra per stabilità). Solleva le gambe with ginocchia piegate a 90°.',
    ),
    execution: Value(
      "Contrai l'addome per sollevare il bacino da terra, portando le ginocchia verso il petto. Il movemento è controllato (non uno slancio). Ritorna lentamente.",
    ),
    tips: Value(
      'Focalizzati sul sollevare il bacino (retroversione), non solo sullo slanciare le gambe.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Plank'),
    targetMuscle: Value('Addominali'),
    equipment: Value('Corpo libero, Tappetino'),
    isBodyweight: Value(true),
    focusArea: Value('Core (Trasverso, Retto), Stabilità totale'),
    preparation: Value(
      'Posizionati sugli avambracci (paralleli o mani giunte) e sulle punte dei piedi. Corpo dritto come una tavola (testa, spalle, bacino, talloni allineati).',
    ),
    execution: Value(
      'Mantieni la posizione contraendo addome e glutei. Non far cadere il bacino (iperlordosi) e non alzarlo troppo.',
    ),
    tips: Value(
      "Respira regolarmente. Contrai attivamente glutei e addome (\"tira l'ombelico verso la colonna\") per massima efficacia.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Side Plank'),
    targetMuscle: Value('Addominali'),
    equipment: Value('Corpo libero, Tappetino'),
    isBodyweight: Value(true),
    focusArea: Value('Obliqui, Quadrato dei lombi, Gluteo medio'),
    preparation: Value(
      'Appoggiati su un avambraccio (gomito sotto la spalla) e sul lato del piede. Corpo dritto lateralmente.',
    ),
    execution: Value(
      'Solleva il fianco da terra e mantieni la linea retta. Non lasciare che il fianco "cada" verso il pavimento.',
    ),
    tips: Value(
      'Per facilitare, appoggia il ginocchio inferiore. Per intensificare, solleva la gamba superiore.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Sollevamento gambe'),
    targetMuscle: Value('Addominali'),
    equipment: Value("Sbarra per trazioni (o apposita 'Captain's Chair')"),
    focusArea: Value("Retto dell'addome (parte bassa), Flessori dell'anca"),
    preparation: Value('Appeso alla sbarra (presa salda). Corpo fermo.'),
    execution: Value(
      'Solleva le gambe tese (o quasi tese) fino a formare 90 gradi (parallele al suolo) o più in alto. Scendi in modo controllato senza dondolare.',
    ),
    tips: Value(
      'Evita di dondolare (usa il core per stabilizzare). Se troppo difficile, inizia with le ginocchia (Knee Raises).',
    ),
  ),
  ExercisesCompanion(
    name: Value('Sollevamento ginocchia'),
    targetMuscle: Value('Addominali'),
    equipment: Value("Sbarra per trazioni (o 'Captain's Chair')"),
    focusArea: Value("Retto dell'addome (parte bassa), Flessori dell'anca"),
    preparation: Value('Appeso alla sbarra.'),
    execution: Value(
      "Solleva le ginocchia verso il petto, contraendo l'addome e sollevando leggermente il bacino in cima (retroversione). Scendi controllato.",
    ),
    tips: Value('Versione più facile del "Leg Raises", ottima per iniziare.'),
  ),
  ExercisesCompanion(
    name: Value('Sollevamento gambe a terra'),
    targetMuscle: Value('Addominali'),
    equipment: Value('Corpo libero, Tappetino'),
    isBodyweight: Value(true),
    focusArea: Value("Retto dell'addome (parte bassa), Flessori dell'anca"),
    preparation: Value(
      'Sdraiato supino, gambe tese. Mani sotto i glutei (per supporto lombare) o lungo i fianchi.',
    ),
    execution: Value(
      'Solleva le gambe tese fino alla verticale (90 gradi). Scendi lentamente senza toccare terra with i talloni.',
    ),
    tips: Value(
      'Mantieni la zona lombare premuta a terra per tutto il movemento. Se si inarca, piega leggermente le ginocchia o riduci il ROM.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Russian Twist'),
    targetMuscle: Value('Addominali'),
    equipment: Value('Disco, Manubrio, Kettlebell (opzionale)'),
    focusArea: Value("Obliqui, Retto dell'addome (rotazione)"),
    preparation: Value(
      'Seduto a terra, ginocchia piegate, talloni a terra (facile) o sollevati (difficile). Busto inclinato indietro (V-sit). Tieni un peso (opzionale) with entrambe le mani.',
    ),
    execution: Value(
      "Ruota il busto e il peso da un lato all'altro, toccando (o quasi) il pavimento di fianco. Muovi spalle e petto, non solo le braccia.",
    ),
    tips: Value(
      'Mantieni la schiena dritta (non curva). Il movemento deve provenire dalla rotazione del core.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Bicycle Crunch'),
    targetMuscle: Value('Addominali'),
    equipment: Value('Corpo libero, Tappetino'),
    isBodyweight: Value(true),
    focusArea: Value("Retto dell'addome, Obliqui (molto completo)"),
    preparation: Value(
      'Supino, mani ai lati della testa. Solleva spalle e gambe da terra.',
    ),
    execution: Value(
      'Porta il gomito destro verso il ginocchio sinistro, mentre estendi la gamba destra. Alterna in modo fluido ("pedalando") e controllato. Ruota il busto.',
    ),
    tips: Value(
      'Non tirare il collo. Il movemento deve essere controllato, non una "corsa" veloce e senza senso. Concentrati sulla rotazione del torso.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Crunch ai cavi in ginocchio'),
    targetMuscle: Value('Addominali'),
    equipment: Value('Cavo (Ercolina), Corda'),
    focusArea: Value("Retto dell'addome (with sovraccarico)"),
    preparation: Value(
      'Posiziona la carrucola in alto with la corda. Inginocchiati di fronte, afferra la corda e portala ai lati della testa/collo.',
    ),
    execution: Value(
      "Contrai l'addome flettendo il busto (\"accartocciati\") verso il pavimento, portando i gomiti verso le ginocchia. Espira forte. Ritorna controllato.",
    ),
    tips: Value(
      "Permette di sovraccaricare l'addome come un qualsiasi altro muscolo. Mantieni i fianchi fermi; il movemento è una flessione spinale.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Ab Rollout'),
    targetMuscle: Value('Addominali'),
    equipment: Value('Ruota addominale (Ab Wheel)'),
    focusArea: Value("Core (anti-estensione), Retto dell'addome, Dorsali"),
    preparation: Value('In ginocchio (su un tappetino), afferra la ruota.'),
    execution: Value(
      'Fai rotolare la ruota in avanti lentamente, estendendo il corpo il più possibile mantenendo la schiena neutra (non inarcare!). Ritorna alla posizione iniziale contraendo addome e dorsali.',
    ),
    tips: Value(
      'Esercizio avanzato. Inizia with un ROM breve. Il core deve lavorare per impedire alla schiena di collassare (anti-estensione).',
    ),
  ),
  ExercisesCompanion(
    name: Value('Toes to Bar'),
    targetMuscle: Value('Addominali'),
    equipment: Value('Sbarra per trazioni'),
    focusArea: Value("Retto dell'addome, Flessori anca (avanzato)"),
    preparation: Value('Appeso alla sbarra.'),
    execution: Value(
      "Contrai l'addome e solleva le gambe tese fino a toccare la sbarra with le punte dei piedi. Scendi in modo controllato.",
    ),
    tips: Value(
      "Richiede molta forza e flessibilità. Spesso eseguito with \"kipping\" (slancio) nel CrossFit, ma per l'ipertrofia è meglio la versione controllata (strict).",
    ),
  ),
  ExercisesCompanion(
    name: Value('V-Ups'),
    targetMuscle: Value('Addominali'),
    equipment: Value('Corpo libero, Tappetino'),
    isBodyweight: Value(true),
    focusArea: Value("Retto dell'addome (parte alta e bassa)"),
    preparation: Value('Supino, braccia tese oltre la testa, gambe tese.'),
    execution: Value(
      'Contrai l\'addome sollevando contemporaneamente busto e gambe tese, cercando di toccare le punte dei piedi a metà strada (formando una "V"). Ritorna controllato.',
    ),
    tips: Value(
      'Esercizio completo e difficile. Se troppo intenso, piega le ginocchia (Tuck-Ups).',
    ),
  ),
  ExercisesCompanion(
    name: Value('Hollow Body Hold'),
    targetMuscle: Value('Addominali'),
    equipment: Value('Corpo libero, Tappetino'),
    isBodyweight: Value(true),
    focusArea: Value('Core (Trasverso, Retto), Stabilità (base ginnastica)'),
    preparation: Value(
      "Supino. Contrai l'addome spingendo la zona lombare a terra (fondamentale!). Solleva testa, spalle e gambe tese di pochi cm da terra. Braccia tese oltre la testa o lungo i fianchi.",
    ),
    execution: Value(
      'Mantieni la posizione "a barchetta", respirando. La zona lombare NON DEVE staccarsi da terra.',
    ),
    tips: Value(
      'Esercizio isometrico fondamentale per la forza del core. Se la schiena si inarca, piega le ginocchia o alza di più le gambe.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Woodchopper ai cavi'),
    targetMuscle: Value('Addominali'),
    equipment: Value('Cavo (Ercolina), Maniglia o Corda'),
    focusArea: Value('Obliqui, Core (potenza rotazionale)'),
    preparation: Value(
      'Posiziona la carrucola in alto. In piedi di fianco, afferra la maniglia with entrambe le mani.',
    ),
    execution: Value(
      'Tira il cavo diagonalmente verso il basso, ruotando il busto (come se tagliassi legna). Il movemento parte dal core, non dalle braccia. Torna controllato.',
    ),
    tips: Value(
      "Può essere fatto anche dal basso verso l'alto (\"reverse woodchopper\"). Mantieni i piedi saldi e ruota sul perno del bacino/busto.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Pall of Press ai cavi'),
    targetMuscle: Value('Addominali'),
    equipment: Value('Cavo (Ercolina), Maniglia'),
    focusArea: Value('Obliqui, Core (anti-rotazione)'),
    preparation: Value(
      'Posiziona la carrucola a metà altezza. In piedi di fianco al cavo, afferra la maniglia with entrambe le mani e portala al petto.',
    ),
    execution: Value(
      'Fai un passo laterale per mettere in tensione. Spingi le mani dritte davanti a te, estendendo le braccia. Il cavo cercherà di ruotarti; il tuo addome deve impedirlo. Mantieni 1-3 secondi e torna al petto.',
    ),
    tips: Value(
      'Esercizio isometrico di anti-rotazione. Fondamentale per la stabilità del core.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Sit-up'),
    targetMuscle: Value('Addominali'),
    equipment: Value('Corpo libero, Tappetino (o panca GHD)'),
    isBodyweight: Value(true),
    focusArea: Value("Retto dell'addome, Flessori dell'anca"),
    preparation:
        Value('Supino, ginocchia piegate. (Spesso with piedi bloccati).'),
    execution: Value(
      "Solleva l'intero busto da terra fino a portarlo in posizione seduta. Scendi controllato.",
    ),
    tips: Value(
      "Coinvolge molto i flessori dell'anca (psoas). Alcuni lo evitano per stress lombare, preferendo i crunch. Nella versione GHD (Glute Ham Developer) il ROM è estremo.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Dragon Flag'),
    targetMuscle: Value('Addominali'),
    equipment: Value('Panca (o supporto stabile)'),
    focusArea: Value("Core (eccentrica), Retto dell'addome (avanzatissimo)"),
    preparation: Value(
      'Supino su panca, afferra i bordi dietro la testa. Solleva tutto il corpo (come una candela).',
    ),
    execution: Value(
      "Mantenendo il corpo dritto come una tavola (dalle spalle ai piedi), abbassalo lentamente in modo controllato (fase eccentrica) fino quasi a sfiorare la panca. Risali (se riesci) o ripeti solo l'eccentrica.",
    ),
    tips: Value(
      'Reso famoso da Bruce Lee. Esercizio di forza pura del core. Inizia solo with la fase eccentrica (negativa).',
    ),
  ),
  ExercisesCompanion(
    name: Value('Flessioni laterali with manubrio'),
    targetMuscle: Value('Addominali'),
    equipment: Value('Manubrio (o Kettlebell)'),
    focusArea: Value('Obliqui, Quadrato dei lombi'),
    preparation: Value(
      'In piedi, tieni un manubrio pesante in una mano. Busto eretto.',
    ),
    execution: Value(
      "Fletti il busto lateralmente sul lato opposto al peso, contraendo l'obliquo. Risali e fletti leggermente sul lato del peso per allungare.",
    ),
    tips: Value(
      "Lavora principalmente l'obliquo opposto al peso (per non farti cadere). Non tenere manubri in entrambe le mani (si bilanciano, annullando il lavoro).",
    ),
  ),
  ExercisesCompanion(
    name: Value('Mountain Climbers'),
    targetMuscle: Value('Addominali'),
    equipment: Value('Corpo libero, Tappetino'),
    isBodyweight: Value(true),
    focusArea: Value('Core (stabilità), Retto addome, Flessori anca, Cardio'),
    preparation: Value(
      'Posizione di plank a braccia tese (mani sotto le spalle).',
    ),
    execution: Value(
      'Porta un ginocchio al petto in modo dinamico, poi alterna rapidamente (come se "corressi" in posizione plank).',
    ),
    tips: Value(
      "Mantieni il bacino basso e stabile (non deve 'saltare' su e giù). Ottimo come finisher metabolico per l'addome.",
    ),
  ),
];
