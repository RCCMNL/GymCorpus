import 'package:drift/drift.dart';
import 'package:gym_corpus/core/database/database.dart';

/// Exercises for the Biceps (Bicipiti)
const bicepsExercises = [
  ExercisesCompanion(
    name: Value('Curl con bilanciere'),
    targetMuscle: Value('Bicipiti'),
    equipment: Value('Bilanciere (dritto o EZ)'),
    focusArea: Value('Bicipite brachiale (entrambi i capi), Brachiale'),
    preparation: Value(
      "In piedi, schiena dritta, core contratto. Afferra il bilanciere with presa supina (palmi verso l'alto) larghezza spalle.",
    ),
    execution: Value(
      'Fletti i gomiti portando il bilanciere verso le spalle. Contrai il bicipite in cima (contrazione di picco). Scendi lentamente in modo controllato fino alla quasi completa estensione.',
    ),
    tips: Value(
      'Evita di dondolare with la schiena ("cheating"). Mantieni i gomiti fissi ai lati del corpo.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Curl con manubri (In piedi, alternato)'),
    targetMuscle: Value('Bicipiti'),
    equipment: Value('Manubri'),
    focusArea: Value('Bicipite brachiale (enfasi supinazione), Brachiale'),
    preparation: Value(
      'In piedi, manubri ai fianchi with presa neutra (palmi verso il corpo).',
    ),
    execution: Value(
      "Solleva un manubrio flettendo il gomito. Durante la salita, ruota il polso (supinazione) portando il palmo verso l'alto. Contrai in cima. Scendi controllato tornando in presa neutra. Alterna le braccia.",
    ),
    tips: Value(
      'La supinazione attiva massimizza il lavoro del bicipite. Mantieni il busto fermo.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Curl con manubri (Seduto, simultaneo)'),
    targetMuscle: Value('Bicipiti'),
    equipment: Value('Manubri, Panca'),
    focusArea: Value('Bicipite brachiale'),
    preparation: Value(
      'Seduto su una panca (con o senza schienale). Manubri ai lati with presa supina.',
    ),
    execution: Value(
      'Fletti entrambi i gomiti simultaneamente, portando i manubri verso le spalle. Contrai e ritorna lentamente.',
    ),
    tips: Value(
      "La posizione seduta aiuta a limitare il 'cheating' with la schiena.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Curl su Panca Scott'),
    targetMuscle: Value('Bicipiti'),
    equipment: Value('Panca Scott (Preacher bench), Bilanciere EZ'),
    focusArea: Value('Bicipite brachiale (focus capo corto, isolamento)'),
    preparation: Value(
      'Siediti alla panca Scott, posiziona la parte posteriore delle braccia (tricipiti) ben aderente al pad. Afferra il bilanciere EZ with presa supina.',
    ),
    execution: Value(
      'Fletti i gomiti portando il bilanciere verso le spalle. Contrai forte in cima. Scendi lentamente finché le braccia non sono quasi tese.',
    ),
    tips: Value(
      'Non estendere completamente in fondo (iperestensione) per proteggere i gomiti. Isolamento puro.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Curl su Panca Scott'),
    targetMuscle: Value('Bicipiti'),
    equipment: Value('Panca Scott, Manubrio'),
    focusArea: Value('Bicipite brachiale (isolamento unilaterale)'),
    preparation: Value(
      'Come la versione with bilanciere, ma usando un solo manubrio. Appoggia il braccio sul pad.',
    ),
    execution: Value(
      'Esegui il curl concentrandoti sulla singola contrazione. Permette di correggere squilibri e massimizzare la supinazione.',
    ),
    tips: Value('Ottimo per la connessione mente-muscolo.'),
  ),
  ExercisesCompanion(
    name: Value('Curl Hammer'),
    targetMuscle: Value('Bicipiti'),
    equipment: Value('Manubri'),
    focusArea: Value('Brachioradiale (avambraccio), Brachiale, Bicipite'),
    preparation: Value(
      'In piedi o seduto. Afferra i manubri with presa neutra (a martello, palmi che si fronteggiano).',
    ),
    execution: Value(
      'Fletti i gomiti portando i manubri verso le spalle, mantenendo sempre la presa neutra. Scendi controllato.',
    ),
    tips: Value(
      'Questo esercizio costruisce spessore nel braccio e rinforza molto gli avambracci.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Curl Hammer'),
    targetMuscle: Value('Bicipiti'),
    equipment: Value('Cavo (Ercolina), Corda'),
    focusArea: Value('Brachioradiale, Brachiale (tensione costante)'),
    preparation: Value(
      'Posiziona la carrucola in basso. Afferra la corda with entrambe le mani (presa neutra).',
    ),
    execution: Value(
      'Esegui un curl a martello tirando la corda verso le spalle. Apri leggermente le mani in cima per aumentare la contrazione. Ritorna lentamente.',
    ),
    tips: Value('Il cavo offre una tensione continua che manca ai manubri.'),
  ),
  ExercisesCompanion(
    name: Value('Curl di concentrazione'),
    targetMuscle: Value('Bicipiti'),
    equipment: Value('Manubrio, Panca'),
    focusArea: Value('Bicipite brachiale (focus contrazione di picco)'),
    preparation: Value(
      "Seduto sul bordo di una panca, gambe divaricate. Appoggia il gomito all'interno della coscia, braccio teso verso il pavimento.",
    ),
    execution: Value(
      'Fletti il gomito portando il manubrio verso il petto, senza muovere la spalla. Contrai forte (picco) per 1-2 secondi. Scendi lentamente.',
    ),
    tips: Value(
      "Esercizio di isolamento per il 'picco' del bicipite. Non usare la gamba per spingere.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Curl su panca inclinata'),
    targetMuscle: Value('Bicipiti'),
    equipment: Value('Manubri, Panca inclinata (45-60°)'),
    focusArea: Value('Bicipite brachiale (focus capo lungo, allungamento)'),
    preparation: Value(
      'Sdraiati su una panca inclinata. Lascia cadere le braccia verticalmente verso il pavimento (presa supina o neutra per iniziare).',
    ),
    execution: Value(
      'Fletti i gomiti (alternati o simultanei), portando i manubri alle spalle. Inizia il movemento with il bicipite già in allungamento.',
    ),
    tips: Value(
      "L'allungamento (stretch) del capo lungo è massimo in questa posizione. Non sollevare le spalle dalla panca.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Zottman Curl'),
    targetMuscle: Value('Bicipiti'),
    equipment: Value('Manubri'),
    focusArea: Value(
      'Bicipite (fase concentrica), Avambracci (fase eccentrica)',
    ),
    preparation: Value('In piedi o seduto. Parti with presa supina (palmi su).'),
    execution: Value(
      'Esegui un normale curl (fase concentrica). In cima, ruota i polsi in presa prona (palmi giù). Scendi lentamente (fase eccentrica) in presa prona. Ruota di nuovo in supinazione in basso.',
    ),
    tips: Value(
      'Esercizio completo che lavora bicipiti in salita e avambracci (brachioradiale) in discesa.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Curl ai cavi bassi'),
    targetMuscle: Value('Bicipiti'),
    equipment: Value('Cavo (Ercolina), Barra (dritto o EZ)'),
    focusArea: Value('Bicipite brachiale (tensione costante)'),
    preparation: Value(
      'Posiziona la carrucola in basso. Afferra la barra (presa supina). Fai un passo indietro.',
    ),
    execution: Value(
      'Esegui un curl come with il bilanciere. Mantieni i gomiti fissi.',
    ),
    tips: Value(
      "Il cavo fornisce una tensione costante per tutto l'arco di movemento, a differenza dei pesi liberi.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Curl ai cavi alti'),
    targetMuscle: Value('Bicipiti'),
    equipment: Value('Cavi (Ercolina, stazione doppia), Maniglie'),
    focusArea: Value('Bicipite brachiale (contrazione di picco)'),
    preparation: Value(
      "Posiziona entrambe le carrucole in alto. Mettiti al centro e afferra le maniglie (una per mano). Braccia aperte a 'T' (posizione 'doppio bicipite').",
    ),
    execution: Value(
      'Fletti i gomiti portando le maniglie verso le orecchie, contraendo forte i bicipiti. Mantieni le spalle ferme. Ritorna controllato.',
    ),
    tips: Value('Esercizio di isolamento estremo per la contrazione di picco.'),
  ),
  ExercisesCompanion(
    name: Value('Reverse Curl with bilanciere'),
    targetMuscle: Value('Bicipiti'),
    equipment: Value('Bilanciere (dritto o EZ)'),
    focusArea: Value(
      'Avambracci (Brachioradiale, Estensori polso), Brachiale',
    ),
    preparation: Value(
      'In piedi. Afferra il bilanciere with presa prona (palmi verso il basso) larghezza spalle.',
    ),
    execution: Value(
      'Fletti i gomiti portando il bilanciere in alto. Mantieni i gomiti fissi ai fianchi. Scendi controllato.',
    ),
    tips: Value(
      'Esercizio primario per gli avambracci (parte superiore) e il muscolo brachiale.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Spider Curl'),
    targetMuscle: Value('Bicipiti'),
    equipment: Value('Panca inclinata (30-45°), Manubri (o Bilanciere EZ)'),
    focusArea: Value('Bicipite brachiale (focus capo corto)'),
    preparation: Value(
      'Sdraiati prono (faccia in giù) su una panca inclinata, petto appoggiato. Lascia cadere le braccia verticalmente.',
    ),
    execution: Value(
      'Fletti i gomiti portando i pesi verso le spalle. Le braccia sono perpendicolari al suolo, eliminando qualsiasi slancio (cheating).',
    ),
    tips: Value(
      'Isolamento totale. La posizione impedisce di usare le spalle o la schiena.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Drag Curl with bilanciere'),
    targetMuscle: Value('Bicipiti'),
    equipment: Value('Bilanciere'),
    focusArea: Value('Bicipite brachiale'),
    preparation: Value('In piedi, afferra il bilanciere (presa supina).'),
    execution: Value(
      "Invece di fare un arco, 'trascina' (drag) il bilanciere lungo il corpo (petto e addome), tirando i gomiti all'indietro. Contrai in cima.",
    ),
    tips: Value(
      'Movemento diverso che pone enfasi sulla contrazione, mantenendo i gomiti dietro il corpo.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Chin-up'),
    targetMuscle: Value('Bicipiti'),
    equipment: Value('Sbarra per trazioni'),
    focusArea: Value('Dorsali, Bicipite brachiale, Romboidi'),
    preparation: Value(
      'Appeso alla sbarra, presa supina (palmi verso di te) larghezza spalle.',
    ),
    execution: Value(
      "Tira il corpo verso l'alto finché il mento non supera la sbarra. Concentrati sulla trazione dei gomiti e sulla contrazione di dorso e bicipiti. Scendi controllato.",
    ),
    tips: Value(
      'Esercizio eccellente per bicipiti e dorso. Spesso si riesce a fare più ripetizioni o with più carico rispetto ai pull-up.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Preacher Curl (Macchina)'),
    targetMuscle: Value('Bicipiti'),
    equipment: Value('Macchinario (Preacher Curl Machine)'),
    focusArea: Value('Bicipite brachiale (isolamento)'),
    preparation: Value(
      "Siediti alla macchina, regola l'altezza. Appoggia le braccia sul pad come per la Panca Scott. Afferra le impugnature.",
    ),
    execution: Value(
      'Fletti i gomiti seguendo il movemento guidato dalla macchina. Contrai in cima e ritorna lentamente.',
    ),
    tips: Value(
      'Simile alla Panca Scott ma with un percorso fisso. Ottimo per principianti.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Curl with elastici'),
    targetMuscle: Value('Bicipiti'),
    equipment: Value('Elastici (Resistance bands)'),
    focusArea: Value('Bicipite brachiale (resistenza progressiva)'),
    preparation: Value(
      "In piedi, fissa l'elastico sotto i piedi. Afferra l'altra estremità with presa supina.",
    ),
    execution: Value(
      'Esegui un curl. La resistenza aumenta man mano che sali (resistenza progressiva), massimizzando la tensione in cima.',
    ),
    tips: Value('Ottimo per allenarsi a casa o come finisher.'),
  ),
  ExercisesCompanion(
    name: Value('Waiter Curl'),
    targetMuscle: Value('Bicipiti'),
    equipment: Value('Manubrio (singolo)'),
    focusArea: Value('Bicipite (Brachiale, Capo lungo)'),
    preparation: Value(
      "Tieni un solo manubrio in posizione 'a coppa' (come un cameriere che porta un vassoio), tenendolo piatto sul palmo della mano.",
    ),
    execution: Value(
      'Fletti il gomito portando il manubrio in alto, mantenendolo orizzontale. Contrai e scendi lentamente.',
    ),
    tips: Value(
      'Stimolo unico che richiede molta stabilità del polso e attiva il brachiale.',
    ),
  ),
];
