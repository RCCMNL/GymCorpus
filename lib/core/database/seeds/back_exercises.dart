import 'package:drift/drift.dart';
import 'package:gym_corpus/core/database/database.dart';

/// Exercises for the Back (Dorso)
const backExercises = [
  ExercisesCompanion(
    name: Value('Pull-ups (presa prona larga)'),
    targetMuscle: Value('Dorso'),
    equipment: Value('Sbarra per trazioni'),
    focusArea: Value('Gran dorsale (ampiezza), Bicipiti, Romboidi'),
    preparation: Value(
      'Afferra la sbarra con una presa prona (palmi lontani da te) molto più larga delle spalle. Parti da una posizione appesa (dead hang), braccia tese.',
    ),
    execution: Value(
      "Tira il corpo verso l'alto, guidando il movemento con i gomiti che spingono verso il basso e all'indietro. Cerca di portare il petto alla sbarra. Scendi in modo controllato fino alla completa estensione.",
    ),
    tips: Value(
      "Focalizzati sul 'tirare' con i muscoli della schiena, non solo con le braccia. Deprimi le scapole prima di iniziare la trazione. Non dondolare.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Chin-ups (presa supina)'),
    targetMuscle: Value('Dorso'),
    equipment: Value('Sbarra per trazioni'),
    focusArea: Value('Bicipiti, Gran dorsale (parte bassa), Romboidi'),
    preparation: Value(
      'Afferra la sbarra con una presa supina (palmi verso di te) larghezza spalle.',
    ),
    execution: Value(
      "Tira il corpo verso l'alto fino a superare la sbarra con il mento. Il focus si sposta maggiormente sui bicipiti rispetto alla presa prona. Scendi controllato.",
    ),
    tips: Value(
      'Esercizio eccellente per bicipiti e dorso. Spesso si riesce a fare più ripetizioni o con più carico rispetto ai pull-up.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Trazioni alla sbarra (presa neutra)'),
    targetMuscle: Value('Dorso'),
    equipment: Value('Sbarra per trazioni (con maniglie parallele / V-Bar)'),
    focusArea: Value('Gran dorsale, Bicipiti, Brachioradiale'),
    preparation: Value(
      "Afferra le maniglie parallele (presa neutra o 'a martello'). Parti da appeso.",
    ),
    execution: Value(
      "Tira il corpo verso l'alto, mantenendo i gomiti vicini al corpo. Questa presa è spesso la più confortevole per le articolazioni di polsi e spalle.",
    ),
    tips: Value(
      'Permette un ottimo equilibrio tra il lavoro del dorsale e quello delle braccia (bicipiti e brachiali).',
    ),
  ),
  ExercisesCompanion(
    name: Value('Lat Machine (presa larga)'),
    targetMuscle: Value('Dorso'),
    equipment: Value('Macchinario (Lat Machine), Barra lunga'),
    focusArea: Value('Gran dorsale (ampiezza)'),
    preparation: Value(
      'Siediti alla macchina, blocca le ginocchia sotto i cuscinetti. Afferra la barra con presa prona larga (come i pull-up).',
    ),
    execution: Value(
      "Tira la barra verso la parte alta del petto, guidando con i gomiti. Contrai la schiena (adduzione scapolare) in basso. Ritorna lentamente, controllando l'eccentrica fino alla quasi estensione.",
    ),
    tips: Value(
      "Non usare lo slancio del busto. Pensa a 'tirare' con i gomiti verso i fianchi. Mantieni il petto 'alto'.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Lat Machine (presa stretta)'),
    targetMuscle: Value('Dorso'),
    equipment: Value('Macchinario (Lat Machine), Barra (o maniglia stretta)'),
    focusArea: Value('Gran dorsale (parte bassa/interna), Bicipiti'),
    preparation: Value(
      'Siediti alla macchina. Afferra la barra con presa supina (palmi verso di te) larghezza spalle o più stretta.',
    ),
    execution: Value(
      'Tira la barra verso il petto, con un arco di movemento simile ai chin-up. Contrai forte bicipiti e dorsali. Ritorna controllato.',
    ),
    tips: Value(
      'Permette di caricare molto e coinvolge intensamente i bicipiti.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Lat Machine (Presa neutra/ V-Bar)'),
    targetMuscle: Value('Dorso'),
    equipment:
        Value('Macchinario (Lat Machine), V-Bar (maniglia stretta neutra)'),
    focusArea: Value('Gran dorsale, Romboidi'),
    preparation: Value('Siediti alla macchina. Aggancia la V-Bar e afferrala.'),
    execution: Value(
      'Tira la maniglia verso il petto. La presa stretta e neutra permette un ottimo allungamento in alto e una forte contrazione in basso.',
    ),
    tips: Value(
      "Molto efficace per colpire la parte 'interna' della schiena.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Rematore con bilanciere'),
    targetMuscle: Value('Dorso'),
    equipment: Value('Bilanciere, Pesi'),
    focusArea: Value(
      'Gran dorsale (spessore), Romboidi, Trapezio, Erettori spinali (isom.)',
    ),
    preparation: Value(
      'Parti con il bilanciere a terra. Piegati in avanti (hip hinge) fino a che il busto è quasi parallelo al suolo (45-70 gradi). Schiena piatta e tesa! Afferra il bilanciere (presa prona o supina).',
    ),
    execution: Value(
      "Tira il bilanciere verso la parte bassa del petto o l'addome, contraendo la schiena e guidando con i gomiti. Ritorna controllato senza poggiare a terra (o poggia per il Pendlay).",
    ),
    tips: Value(
      'La schiena deve rimanere bloccata e piatta per tutto il tempo. La presa supina coinvolge più i bicipiti.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Rematore Pendlay'),
    targetMuscle: Value('Dorso'),
    equipment: Value('Bilanciere, Pesi'),
    focusArea: Value('Dorsali, Trapezio, Schiena (superiore), Erettori'),
    preparation: Value(
      'Parti come un rematore bilanciere, ma il busto DEVE essere parallelo al suolo. Il bilanciere parte da terra ad ogni ripetizione.',
    ),
    execution: Value(
      'Tira il bilanciere esplosivamente verso lo sterno/petto alto. Contrai. Riporta il bilanciere a terra (dead-stop) e ripeti.',
    ),
    tips: Value(
      'Costruisce potenza nella schiena. Elimina lo slancio e lo stress sulla lombare (se eseguito correttamente) perché ogni rep parte da fermo.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Rematore con manubrio'),
    targetMuscle: Value('Dorso'),
    equipment: Value('Manubrio, Panca piana'),
    focusArea: Value('Gran dorsale, Romboidi, Bicipiti (lavoro unilaterale)'),
    preparation: Value(
      "Appoggia un ginocchio e la mano dello stesso lato su una panca piana. Busto parallelo a terra. Afferra il manubrio con l'altra mano, braccio teso.",
    ),
    execution: Value(
      'Tira il manubrio verso il fianco (non verso il petto), seguendo un arco di movemento naturale ("avviando una motosega"). Contrai il dorsale. Ritorna lentamente in allungamento.',
    ),
    tips: Value(
      'Il lavoro unilaterale permette un ROM maggiore e corregge squilibri. Non ruotare il busto.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Rematore al T-Bar'),
    targetMuscle: Value('Dorso'),
    equipment: Value('Bilanciere (angolo landmine) o Macchina T-Bar'),
    focusArea: Value('Dorso (spessore, parte centrale), Trapezio, Romboidi'),
    preparation: Value(
      "Posiziona un'estremità del bilanciere in un angolo (landmine). Carica l'altra estremità. Mettiti a cavalcioni e afferra il bilanciere (con V-Bar o presa diretta). Busto flesso a 45°.",
    ),
    execution: Value(
      'Tira il peso verso il petto, contraendo la schiena. Scendi controllato.',
    ),
    tips: Value(
      "Molto simile al rematore bilanciere, ma l'arco di movemento è fisso e permette di caricare molto peso.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Rematore al cavo basso (Seated Cable Row)'),
    targetMuscle: Value('Dorso'),
    equipment: Value('Macchinario (Pulley), Maniglia (stretta o larga)'),
    focusArea: Value('Dorso (spessore), Romboidi, Trapezio (medio)'),
    preparation: Value(
      'Siediti alla macchina, piedi sugli appoggi, ginocchia leggermente flesse. Afferra la maniglia (es. V-Bar stretta). Schiena dritta.',
    ),
    execution: Value(
      "Tira la maniglia verso l'addome, mantenendo il busto eretto (non dondolare). Tira le scapole indietro e contrai. Ritorna controllato, allungando bene la schiena in avanti (ma senza curvarla).",
    ),
    tips: Value(
      'Presa stretta = più romboidi/spessore. Presa larga = più dorsali/ampiezza.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Rematore con petto in appoggio'),
    targetMuscle: Value('Dorso'),
    equipment: Value('Panca inclinata (30-45°), Manubri (o Bilanciere)'),
    focusArea: Value('Dorso (superiore), Romboidi, Trapezio (isolamento)'),
    preparation: Value(
      'Sdraiati prono (faccia in giù) su una panca inclinata, petto appoggiato. Afferra i manubri.',
    ),
    execution: Value(
      "Tira i manubri verso l'alto, guidando con i gomiti e contraendo le scapole. Il petto rimane sempre appoggiato.",
    ),
    tips: Value(
      'Isola perfettamente i muscoli della schiena eliminando qualsiasi stress lombare o slancio.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Stacco da terra (Deadlift) '),
    targetMuscle: Value('Dorso'),
    equipment: Value('Bilanciere, Pesi'),
    focusArea: Value(
      'Catena posteriore totale, Erettori spinali, Trapezio, Glutei, Ischiocrurali',
    ),
    preparation: Value(
      'Piedi larghezza fianchi sotto il bilanciere. Afferra il bilanciere appena fuori dalle ginocchia. Schiena piatta e tesa, petto in fuori, bacino basso.',
    ),
    execution: Value(
      "Spingi con le gambe 'allontanando il pavimento'. Estendi l'anca quando il bilanciere supera le ginocchia. Contrai glutei e schiena in cima. Scendi in modo controllato.",
    ),
    tips: Value(
      'Esercizio fondamentale per la forza di tutto il corpo. La schiena lavora isometricamente per mantenere la posizione: cruciale per lo spessore (erettori, trapezi).',
    ),
  ),
  ExercisesCompanion(
    name: Value('Stacco Romeno'),
    targetMuscle: Value('Dorso'),
    equipment: Value('Bilanciere o Manubri'),
    focusArea: Value('Ischiocrurali, Glutei, Erettori spinali (isom.)'),
    preparation: Value(
      'Parti in piedi con il bilanciere/manubri in mano. Gambe leggermente piegate (ma fisse).',
    ),
    execution: Value(
      "Spingi il bacino indietro (hip hinge), mantenendo la schiena piatta e il bilanciere vicino alle gambe. Scendi finché senti allungamento. Torna su estendendo l'anca.",
    ),
    tips: Value(
      'Sebbene il focus primario siano gli ischiocrurali, gli erettori spinali lavorano intensamente in isometrica per stabilizzare la colonna.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Hyperextensions'),
    targetMuscle: Value('Dorso'),
    equipment: Value('Panca 45° (Hyperextension) o GHD'),
    focusArea: Value(
      'Erettori spinali (zona lombare), Glutei, Ischiocrurali',
    ),
    preparation: Value(
      'Posizionati sulla panca 45°, caviglie bloccate, bacino sul bordo del pad. Incrocia le braccia al petto (o mani dietro la testa/peso).',
    ),
    execution: Value(
      'Fletti il busto scendendo verso il basso (mantenendo la schiena piatta). Risali usando gli erettori spinali e i glutei, fino a formare una linea retta (non iperestendere!).',
    ),
    tips: Value(
      'Ottimo per rinforzare la parte bassa della schiena. Puoi tenere un disco al petto per aumentare il carico.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Pulldown a braccia tese'),
    targetMuscle: Value('Dorso'),
    equipment: Value('Cavo (Ercolina), Barra (dritta o corda)'),
    focusArea: Value('Gran dorsale (isolamento), Core'),
    preparation: Value(
      'Posiziona la carrucola in alto. Afferra la barra (presa prona). Fai un passo indietro, busto leggermente flesso in avanti, braccia quasi tese.',
    ),
    execution: Value(
      'Mantenendo le braccia tese, tira la barra verso le cosce con un ampio arco di movemento, contraendo i dorsali. Ritorna lentamente.',
    ),
    tips: Value(
      'Esercizio di isolamento puro per i dorsali. Non piegare i gomiti (non è un pushdown per tricipiti).',
    ),
  ),
  ExercisesCompanion(
    name: Value('Pullover'),
    targetMuscle: Value('Dorso'),
    equipment: Value('Manubrio, Panca piana'),
    focusArea:
        Value('Gran dorsale (allungamento), Petto, Serrato anteriore'),
    preparation: Value(
      "Appoggia solo la parte alta della schiena (scapole) di traverso su una panca piana. Piedi a terra, bacino basso. Tieni un manubrio 'a coppa' sopra il petto.",
    ),
    execution: Value(
      "Abbassa il manubrio all'indietro (oltre la testa) con i gomiti leggermente flessi, sentendo un forte allungamento del dorsale e del petto. Ritorna alla posizione iniziale.",
    ),
    tips: Value(
      "Esercizio 'vecchia scuola' per l'espansione della cassa toracica e l'allungamento del gran dorsale.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Rematore inverso'),
    targetMuscle: Value('Dorso'),
    equipment: Value('Sbarra (bassa, es. Multipower) o Anelli/TRX'),
    focusArea: Value('Dorso (superiore), Romboidi, Bicipiti (corpo libero)'),
    preparation: Value(
      'Posiziona una sbarra ad altezza bacino. Mettiti sotto (sdraiato supino), afferra la sbarra (presa prona o supina). Corpo teso (come un plank inverso), talloni a terra.',
    ),
    execution: Value(
      'Tira il petto verso la sbarra, contraendo la schiena. Scendi controllato.',
    ),
    tips: Value(
      'Ottimo esercizio a corpo libero. Più sei orizzontale, più è difficile. Tieni il corpo dritto (non far cadere il bacino).',
    ),
  ),
  ExercisesCompanion(
    name: Value('Scrollate con manubri/bilanciere'),
    targetMuscle: Value('Dorso'),
    equipment: Value('Manubri (pesanti) o Bilanciere'),
    focusArea: Value('Trapezio (superiore)'),
    preparation: Value(
      'In piedi, tieni i manubri pesanti ai lati (o bilanciere davanti).',
    ),
    execution: Value(
      'Solleva ("scrolla") le spalle verticalmente verso le orecchie, senza piegare i gomiti. Contrai il trapezio in cima per 1-2 secondi. Ritorna lentamente.',
    ),
    tips: Value(
      'Il trapezio è un muscolo importante della schiena. Non ruotare le spalle; il movemento è solo verticale.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Face Pull'),
    targetMuscle: Value('Dorso'),
    equipment: Value('Cavo (Ercolina), Corda'),
    focusArea: Value(
      'Trapezio (medio e basso), Deltoidi posteriori, Cuffia rotatori',
    ),
    preparation: Value(
      "Posiziona la carrucola all'altezza degli occhi. Afferra la corda (presa prona). Fai un passo indietro.",
    ),
    execution: Value(
      'Tira la corda verso il viso ("pull"), puntando ai lati della testa. Contemporaneamente, ruota esternamente le spalle (extrarotazione). Contrai forte la parte alta della schiena.',
    ),
    tips: Value(
      'Fondamentale per la salute delle spalle e per bilanciare tutto il lavoro di spinta. Lavora la parte alta del dorso (trapezi/romboidi).',
    ),
  ),
];
