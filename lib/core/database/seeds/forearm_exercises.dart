import 'package:drift/drift.dart';
import 'package:gym_corpus/core/database/database.dart';

/// Exercises for the Forearms (Avambracci)
const forearmExercises = [
  ExercisesCompanion(
    name: Value('Wrist Curls con manubrio'),
    targetMuscle: Value('Avambracci'),
    equipment: Value('Manubrio, Panca (o coscia)'),
    focusArea: Value("Flessori dell'avambraccio"),
    preparation: Value(
      'Seduto, avambraccio appoggiato sulla coscia o sul bordo di una panca. Polso libero. Impugna il manubrio with presa supina (palmo in su).',
    ),
    execution: Value(
      "Fletti il polso portando il manubrio verso l'alto il più possibile (contrazione). Scendi lentamente, lasciando che il manubrio allunghi i flessori, quasi 'rotolando' sulle dita.",
    ),
    tips: Value(
      "Isola il movemento solo al polso. Non muovere l'avambraccio.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Wrist Curls con bilanciere'),
    targetMuscle: Value('Avambracci'),
    equipment: Value('Bilanciere (dritto o EZ), Panca'),
    focusArea: Value("Flessori dell'avambraccio"),
    preparation: Value(
      "Seduto, entrambi gli avambracci appoggiati su una panca piana (o sulle cosce), polsi liberi all'esterno. Presa supina sul bilanciere.",
    ),
    execution: Value(
      "Fletti entrambi i polsi simultaneamente verso l'alto. Contrai. Scendi lentamente, permettendo al bilanciere di rotolare verso la punta delle dita per un ROM maggiore.",
    ),
    tips: Value(
      'La versione with bilanciere permette carichi maggiori. Controlla la discesa.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Reverse Wrist Curls'),
    targetMuscle: Value('Avambracci'),
    equipment: Value('Manubrio o Bilanciere, Panca'),
    focusArea: Value("Estensori dell'avambraccio (parte superiore)"),
    preparation: Value(
      'Come i wrist curls, ma with presa prona (palmo in giù). Avambraccio appoggiato sulla coscia o panca, polso libero.',
    ),
    execution: Value(
      "Estendi il polso sollevando il dorso della mano verso l'alto (verso il soffitto). Contrai gli estensori. Ritorna lentamente.",
    ),
    tips: Value(
      'Richiede un carico significativamente inferiore rispetto ai curl per flessori. Movemento lento e controllato.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Curl Hammer'),
    targetMuscle: Value('Avambracci'),
    equipment: Value('Manubri'),
    focusArea: Value('Brachioradiale (avambraccio), Brachiale, Bicipite'),
    preparation: Value(
      'In piedi o seduto. Afferra i manubri with presa neutra (a martello, palmi che si fronteggiano).',
    ),
    execution: Value(
      'Fletti i gomiti portando i manubri verso le spalle, mantenendo sempre la presa neutra. Scendi controllato.',
    ),
    tips: Value(
      "Esercizio fondamentale per costruire spessore nell'avambraccio (brachioradiale).",
    ),
  ),
  ExercisesCompanion(
    name: Value('Reverse Barbell Curl'),
    targetMuscle: Value('Avambracci'),
    equipment: Value('Bilanciere (dritto o EZ)'),
    focusArea: Value('Brachioradiale, Estensori del polso, Brachiale'),
    preparation: Value(
      'In piedi. Afferra il bilanciere with presa prona (palmi verso il basso) larghezza spalle.',
    ),
    execution: Value(
      'Fletti i gomiti portando il bilanciere in alto, mantenendo i gomiti fissi ai fianchi. Scendi controllato.',
    ),
    tips: Value(
      'Esercizio primario per la parte superiore degli avambracci e per la forza dei polsi in estensione.',
    ),
  ),
  ExercisesCompanion(
    name: Value("Farmer's Walk"),
    targetMuscle: Value('Avambracci'),
    equipment: Value("Manubri pesanti, Kettlebell, o Farmer's Walk handles"),
    focusArea: Value(
      'Forza della presa (Grip strength), Trapezi, Core, Stabilizzatori',
    ),
    preparation: Value(
      'Stacca da terra due manubri/kettlebell pesanti (come uno stacco). Stai in piedi dritto, petto in fuori, core contratto, spalle depresse.',
    ),
    execution: Value(
      'Cammina a passi controllati ma decisi per una distanza o un tempo prestabiliti. Mantieni la postura eretta, non inclinarti e non dondolare.',
    ),
    tips: Value(
      'Uno dei migliori esercizi totali per la forza della presa (resistenza isometrica).',
    ),
  ),
  ExercisesCompanion(
    name: Value('Hand Grippers'),
    targetMuscle: Value('Avambracci'),
    equipment: Value('Hand Grippers (pinze a molla)'),
    focusArea: Value('Forza della presa (schiacciamento, crushing grip)'),
    preparation: Value(
      'Impugna la pinza with una mano. Posizionala correttamente nel palmo.',
    ),
    execution: Value(
      'Chiudi la pinza (schiaccia) fino a far toccare le due impugnature (se possibile). Mantieni la contrazione per 1-2 secondi. Rilascia lentamente (controllo eccentrico).',
    ),
    tips: Value(
      'Ottimo per aumentare la forza di schiacciamento. Lavora su basse rep (forza) o alte rep (resistenza).',
    ),
  ),
  ExercisesCompanion(
    name: Value('Plate Pinch'),
    targetMuscle: Value('Avambracci'),
    equipment: Value('Dischi (preferibilmente lisci)'),
    focusArea: Value('Forza della presa (dita, pinza, pinch grip)'),
    preparation: Value(
      "Posiziona due dischi della stessa dimensione uno contro l'altro, with il lato liscio rivolto verso l'esterno.",
    ),
    execution: Value(
      "Afferra i dischi solo with le dita e il pollice (presa 'a pinza'). Sollevali da terra e tienili il più a lungo possibile (isometria) o cammina.",
    ),
    tips: Value(
      'Esercizio brutale per la forza delle dita e del pollice. Inizia with dischi leggeri (es. 2x5kg o 2x10kg).',
    ),
  ),
  ExercisesCompanion(
    name: Value('Sospensioni alla sbarra (Dead Hang)'),
    targetMuscle: Value('Avambracci'),
    equipment: Value('Sbarra per trazioni'),
    focusArea: Value('Resistenza della presa, Decompressione spinale'),
    preparation:
        Value('Afferra la sbarra (presa prona o supina) larghezza spalle.'),
    execution: Value(
      'Rimani appeso alla sbarra (piedi sollevati da terra) per il tempo massimo possibile (time under tension).',
    ),
    tips: Value(
      'Esercizio isometrico fondamentale per la resistenza della presa. Prova anche la sospensione a un braccio o with asciugamani per aumentare la difficoltà.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Avvolgimento del polso (Wrist Roller)'),
    targetMuscle: Value('Avambracci'),
    equipment: Value('Wrist roller (rullo per polsi) e peso'),
    focusArea: Value('Flessori ed Estensori (resistenza, ipertrofia)'),
    preparation: Value(
      'Tieni il wrist roller davanti a te a braccia tese (più difficile) o piegate. Il peso è appeso alla corda, vicino a terra.',
    ),
    execution: Value(
      'Avvolgi la corda attorno al rullo ruotando i polsi (sia in estensione che in flessione) fino a che il peso non arriva in cima. Svolgi lentamente (controllo eccentrico).',
    ),
    tips: Value(
      "Brucia incredibilmente gli avambracci. Assicurati di allenare sia il movemento di 'avvolgimento' (estensione) che quello di 'svolgimento' (flessione).",
    ),
  ),
];
