import 'package:drift/drift.dart';
import 'package:gym_corpus/core/database/database.dart';

/// Exercises for the Shoulders (Spalle)
const shoulderExercises = [
  ExercisesCompanion(
    name: Value('Overhead Press con bilanciere'),
    targetMuscle: Value('Spalle'),
    equipment: Value('Bilanciere, Rack (opzionale)'),
    focusArea: Value('Deltoidi (anteriori, mediali), Tricipiti, Trapezio'),
    preparation: Value(
      'In piedi, afferra il bilanciere with presa prona (palmi avanti) leggermente più larga delle spalle. Porta il bilanciere al petto alto/clavicole (puoi staccarlo da un rack). Core contratto, glutei contratti.',
    ),
    execution: Value(
      'Spingi il bilanciere verticalmente sopra la testa fino alla completa estensione delle braccia, senza iperestendere la schiena. Il bilanciere termina sopra la nuca. Scendi in modo controllato tornando alla posizione iniziale.',
    ),
    tips: Value(
      "Mantieni l'addome contratto per evitare di inarcare la schiena. Pensa a 'infilare la testa sotto' il bilanciere nella fase finale.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Overhead Press con manubri'),
    targetMuscle: Value('Spalle'),
    equipment: Value('Manubri, Panca (se seduto)'),
    focusArea: Value(
      'Deltoidi (anteriori, mediali), Tricipiti, Stabilizzatori',
    ),
    preparation: Value(
      "Seduto su panca with schienale a 90° o in piedi. Porta i manubri all'altezza delle spalle, palmi rivolti in avanti (o semi-proni per più comfort).",
    ),
    execution: Value(
      'Spingi i manubri verticalmente sopra la testa, convergendo leggermente in cima senza farli toccare. Ritorna lentamente alla posizione di partenza (gomiti a 90 gradi o leggermente sotto).',
    ),
    tips: Value(
      'I manubri permettono un ROM più naturale rispetto al bilanciere. La versione seduta isola di più le spalle.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Arnold Press'),
    targetMuscle: Value('Spalle'),
    equipment: Value('Manubri, Panca (consigliata)'),
    focusArea: Value('Deltoidi (tutti i capi, focus anteriore e mediale)'),
    preparation: Value(
      'Seduto su panca. Parti with i manubri davanti al petto, palmi rivolti verso di te (presa supina).',
    ),
    execution: Value(
      "Inizia spingendo verso l'alto. Mentre sali, ruota i polsi in modo che i palmi guardino in avanti nella parte finale del movemento (come una \"OHP\" with manubri). Inverti il movemento in discesa, tornando alla posizione supina iniziale.",
    ),
    tips: Value(
      'Movemento fluido e controllato, non a scatti. Combina una spinta with una rotazione, lavorando i capi del deltoide in modi diversi.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Alzate laterali(Manubri)'),
    targetMuscle: Value('Spalle'),
    equipment: Value('Manubri'),
    focusArea: Value('Deltoidi (mediali/laterali)'),
    preparation: Value(
      'In piedi (o seduto), manubri ai lati del corpo, palmi rivolti verso i fianchi. Ginocchia e gomiti leggermente flessi.',
    ),
    execution: Value(
      "Solleva i manubri lateralmente fino all'altezza delle spalle. Pensa a \"spingere\" i manubri verso le pareti laterali, non a \"tirarli\" su. Il mignolo dovrebbe essere idealmente alla stessa altezza (o leggermente più su) del pollice.",
    ),
    tips: Value(
      "Esercizio di isolamento. Non usare slancio (\"cheating\") e non superare l'altezza delle spalle. Mantieni il busto fermo.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Alzate laterali ai cavi'),
    targetMuscle: Value('Spalle'),
    equipment: Value('Cavo (Ercolina), Maniglia'),
    focusArea: Value('Deltoidi (mediali, tensione costante)'),
    preparation: Value(
      'Posiziona la carrucola in basso. Afferra la maniglia with la mano opposta al cavo (es. mano dx, cavo a sx). Fai un passo laterale per mettere in tensione.',
    ),
    execution: Value(
      "Esegui un'alzata laterale come with i manubri. Il cavo offre una tensione costante per tutto l'arco di movemento, specialmente in basso.",
    ),
    tips: Value(
      "Puoi tenerti a un supporto with l'altra mano per stabilizzare il corpo. Concentrati sul deltoide mediale.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Alzate frontali'),
    targetMuscle: Value('Spalle'),
    equipment: Value('Manubri'),
    focusArea: Value('Deltoidi (anteriori)'),
    preparation: Value(
      'In piedi, manubri davanti alle cosce, palmi rivolti verso il corpo (presa prona).',
    ),
    execution: Value(
      "Solleva un manubrio (o entrambi) dritto davanti a te fino all'altezza degli occhi/spalle. Mantieni il braccio quasi teso (leggera flessione gomito). Ritorna controllato. Alterna le braccia o eseguile insieme.",
    ),
    tips: Value(
      'Evita di usare slancio o di inarcare la schiena. Il deltoide anteriore è già molto stimolato dalle spinte (es. panca piana, OHP).',
    ),
  ),
  ExercisesCompanion(
    name: Value('Alzate frontali'),
    targetMuscle: Value('Spalle'),
    equipment: Value('Disco (bumper/ghisa) o Bilanciere (dritto o EZ)'),
    focusArea: Value('Deltoidi (anteriori)'),
    preparation: Value(
      "Afferra un disco ai lati ('presa volante') o un bilanciere with presa larghezza spalle.",
    ),
    execution: Value(
      "Solleva l'attrezzo davanti a te fino all'altezza delle spalle/occhi. Mantieni il core contratto per stabilizzare.",
    ),
    tips: Value(
      'Simile ai manubri, ma il bilanciere richiede più stabilizzazione e il disco offre una presa diversa.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Alzate posteriori a 90'),
    targetMuscle: Value('Spalle'),
    equipment: Value('Manubri, Panca (opzionale)'),
    focusArea: Value('Deltoidi (posteriori), Romboidi, Trapezio (medio)'),
    preparation: Value(
      'In piedi, piega il busto in avanti a 90° (schiena piatta!) o siediti sul bordo di una panca e piegati in avanti. Tieni i manubri sotto il petto, palmi che si fronteggiano.',
    ),
    execution: Value(
      'Solleva i manubri lateralmente (come un uccello che apre le ali), mantenendo i gomiti leggermente flessi. Contrai le scapole in cima. Ritorna controllato.',
    ),
    tips: Value(
      'Non tirare with la schiena, il movemento parte dalle spalle. Usa pesi leggeri e concentrati sulla contrazione dei deltoidi posteriori.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Alzate posteriori ai cavi'),
    targetMuscle: Value('Spalle'),
    equipment: Value('Cavi (Ercolina)'),
    focusArea: Value('Deltoidi (posteriori), Romboidi'),
    preparation: Value(
      'Posiziona le carrucole a metà altezza o alte. Afferra le maniglie incrociandole (cavo dx with mano sx, cavo sx with mano dx). Fai un passo indietro.',
    ),
    execution: Value(
      "Apri le braccia ('tira') lateralmente e all'indietro, mantenendo le braccia quasi tese. Contrai i deltoidi posteriori. Ritorna lentamente.",
    ),
    tips: Value(
      "Tensione costante ottima per l'isolamento dei deltoidi posteriori. Mantieni il petto 'in fuori' e la schiena dritta.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Face Pull'),
    targetMuscle: Value('Spalle'),
    equipment: Value('Cavo (Ercolina), Corda'),
    focusArea: Value(
      'Deltoidi (posteriori), Cuffia dei rotatori, Trapezio (medio)',
    ),
    preparation: Value(
      "Posiziona la carrucola all'altezza degli occhi o del petto. Afferra la corda with presa prona (pollici verso di te). Fai un passo indietro.",
    ),
    execution: Value(
      'Tira la corda verso il viso ("pull"), puntando ai lati della testa (altezza orecchie/occhi). Contemporaneamente, ruota esternamente le spalle (extrarotazione). Contrai forte in cima.',
    ),
    tips: Value(
      "Fondamentale per la salute delle spalle. Non usare troppo peso. Il focus è sulla contrazione posteriore e sull'extrarotazione.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Tirate al mento with bilanciere'),
    targetMuscle: Value('Spalle'),
    equipment: Value('Bilanciere'),
    focusArea: Value('Deltoidi (mediali), Trapezio'),
    preparation: Value(
      'Afferra il bilanciere with una presa larga (più larga delle spalle). Parti with il bilanciere alle cosce.',
    ),
    execution: Value(
      "Tira il bilanciere verso l'alto lungo il corpo, guidando il movemento with i gomiti (i gomiti salgono alti e larghi). Fermati quando il bilanciere arriva al petto (non al mento).",
    ),
    tips: Value(
      "La presa larga è fondamentale per focalizzarsi sui deltoidi mediali e ridurre l'impingement (schiacciamento) della spalla, a differenza della presa stretta.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Tirate al mento (Manubri)'),
    targetMuscle: Value('Spalle'),
    equipment: Value('Manubri'),
    focusArea: Value('Deltoidi (mediali), Trapezio'),
    preparation: Value('Tieni i manubri davanti a te (palmi verso il corpo).'),
    execution: Value(
      "Tira i manubri verso l'alto, guidando with i gomiti. I manubri permettono un movemento più libero rispetto al bilanciere, potenzialmente più sicuro per le spalle.",
    ),
    tips: Value(
      'Come per il bilanciere, guida with i gomiti e non portare i pesi troppo in alto (altezza petto va bene).',
    ),
  ),
  ExercisesCompanion(
    name: Value('Neck Press)'),
    targetMuscle: Value('Spalle'),
    equipment: Value('Bilanciere, Rack'),
    focusArea: Value('Deltoidi (mediali, anteriori), Tricipiti'),
    preparation: Value(
      'Posiziona il bilanciere sulla nuca/trapezi (come uno squat). Presa larga.',
    ),
    execution: Value(
      'Spingi il bilanciere verticalmente sopra la testa. Scendi controllato tornando dietro la nuca.',
    ),
    tips: Value(
      "ATTENZIONE: Richiede un'ottima mobilità delle spalle (extrarotazione) e toracica. Molte persone non hanno la mobilità per eseguirlo in sicurezza. Procedere with cautela e pesi bassi.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Push Press'),
    targetMuscle: Value('Spalle'),
    equipment: Value('Bilanciere, Rack'),
    focusArea: Value('Spalle (potenza), Deltoidi, Tricipiti, Gambe (spinta)'),
    preparation: Value(
      'Posizione di partenza come una OHP (bilanciere sulle clavicole).',
    ),
    execution: Value(
      "Esegui un rapido 'dip' (mini-squat) piegando leggermente le ginocchia. Immediatamente, spingi with forza with le gambe e contemporaneamente spingi il bilanciere sopra la testa in modo esplosivo.",
    ),
    tips: Value(
      'È un movemento di potenza, non di ipertrofia pura. Usa lo slancio (leg drive) delle gambe per muovere più carico. Scendi in modo controllato (eccentrica).',
    ),
  ),
  ExercisesCompanion(
    name: Value('Reverse Pec Deck'),
    targetMuscle: Value('Spalle'),
    equipment: Value('Macchinario (Pec Deck / Rear Delt)'),
    focusArea: Value('Deltoidi (posteriori)'),
    preparation: Value(
      'Siediti sulla macchina al contrario (faccia verso lo schienale). Regola il sedile. Afferra le impugnature (presa prona o neutra).',
    ),
    execution: Value(
      "Apri le braccia all'indietro, mantenendole quasi tese. Contrai i deltoidi posteriori. Ritorna lentamente.",
    ),
    tips: Value(
      'Puro isolamento per i deltoidi posteriori. Non usare slancio e concentrati sulla contrazione di picco.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Landmine Press'),
    targetMuscle: Value('Spalle'),
    equipment: Value('Bilanciere, Supporto Landmine'),
    focusArea: Value(
      'Deltoide (anteriore), Pettorale (clavicolare), Tricipiti',
    ),
    preparation: Value(
      "In ginocchio o in piedi. Afferra l'estremità libera del bilanciere with una mano all'altezza della spalla.",
    ),
    execution: Value(
      "Spingi il bilanciere verso l'alto e in avanti, estendendo il braccio. Contrai spalla e petto alto. Ritorna controllato.",
    ),
    tips: Value(
      'Movemento unilaterale che segue un arco naturale, spesso più confortevole per le spalle rispetto alla OHP verticale.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Pike Push-up'),
    targetMuscle: Value('Spalle'),
    equipment: Value('Corpo libero'),
    focusArea: Value('Deltoidi (anteriori, mediali), Tricipiti'),
    preparation: Value(
      "Posizione di 'V' rovesciata (Down-Dog nello yoga). Mani larghezza spalle, sedere alto.",
    ),
    execution: Value(
      'Piega i gomiti, abbassando la testa verso il pavimento (la testa punta "avanti" rispetto alle mani, formando un triangolo). Spingi tornando su, concentrandoti sulle spalle.',
    ),
    tips: Value(
      'Propedeutico per i piegamenti in verticale. Più le mani sono vicine ai piedi, più è difficile.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Handstand Push-up'),
    targetMuscle: Value('Spalle'),
    equipment: Value('Corpo libero, Muro (per supporto)'),
    focusArea: Value('Deltoidi, Tricipiti, Trapezio (avanzato)'),
    preparation: Value(
      'Posizionati in verticale (handstand) with i talloni appoggiati al muro per equilibrio.',
    ),
    execution: Value(
      'Piega lentamente i gomiti, abbassando la testa verso il pavimento (idealmente su un cuscino o pad). Spingi with forza per tornare alla posizione di partenza.',
    ),
    tips: Value(
      'Esercizio molto avanzato. Richiede grande forza nelle spalle e nel core. Inizia with i Pike Push-up o with ROM ridotto.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Cuban Press'),
    targetMuscle: Value('Spalle'),
    equipment: Value('Manubri (molto leggeri)'),
    focusArea: Value('Cuffia dei rotatori, Deltoidi (posteriori, mediali)'),
    preparation: Value(
      "Parti come un'alzata posteriore (busto a 90° o prono su panca inclinata). Solleva i manubri (gomiti a 90°). Da lì, ruota esternamente le spalle (alzando i manubri).",
    ),
    execution: Value(
      'Il movemento completo (spesso fatto in piedi) è: Tirata al mento (gomiti alti) -> Extrarotazione -> Spinta (Overhead Press). Eseguilo molto lentamente.',
    ),
    tips: Value(
      'Esercizio complesso per la salute e il rinforzo della cuffia dei rotatori. Usa pesi BASSISSIMI (1-3kg).',
    ),
  ),
  ExercisesCompanion(
    name: Value('Scrollate with manubri'),
    targetMuscle: Value('Spalle'),
    equipment: Value('Manubri (pesanti)'),
    focusArea: Value('Trapezio (superiore)'),
    preparation: Value('In piedi, manubri pesanti ai lati del corpo.'),
    execution: Value(
      'Solleva le spalle ("scrolla") verticalmente verso le orecchie, senza piegare i gomiti. Contrai il trapezio in cima per 1-2 secondi. Ritorna lentamente.',
    ),
    tips: Value(
      'Non ruotare le spalle (indietro o avanti), è un movemento puramente verticale. Il trapezio risponde bene a carichi pesanti e contrazioni.',
    ),
  ),
];
