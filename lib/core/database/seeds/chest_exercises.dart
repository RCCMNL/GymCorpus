import 'package:drift/drift.dart';
import 'package:gym_corpus/core/database/database.dart';

/// Exercises for the Chest (Petto)
const chestExercises = [
  ExercisesCompanion(
    name: Value('Distensioni su panca piana (Bilanciere)'),
    targetMuscle: Value('Petto'),
    equipment: Value('Panca piana, Bilanciere, Rack'),
    focusArea: Value(
      'Pettorali (focus sterno-costale), Tricipiti, Deltoidi anteriori',
    ),
    preparation: Value(
      'Sdraiati sulla panca piana. Afferra il bilanciere con una presa leggermente più larga delle spalle. Stacca il bilanciere dal rack e portalo sopra il petto a braccia tese. Mantieni le scapole addotte e depresse (assetto scapolare).',
    ),
    execution: Value(
      "Abbassa lentamente il bilanciere fino a sfiorare la parte centrale del petto (linea dei capezzoli), mantenendo i gomiti a circa 45-60 gradi rispetto al busto. Spingi con forza il bilanciere verso l'alto fino a tornare alla posizione iniziale, senza bloccare completamente i gomiti.",
    ),
    tips: Value(
      'Mantieni sempre i piedi ben saldi a terra e il gluteo a contatto con la panca. Un arco lombare fisiologico è corretto e aiuta nella stabilità. Controlla la fase eccentrica (discesa).',
    ),
  ),
  ExercisesCompanion(
    name: Value('Distensioni su panca piana (Manubri)'),
    targetMuscle: Value('Petto'),
    equipment: Value('Panca piana, Manubri'),
    focusArea: Value(
      'Pettorali (focus sterno-costale), Deltoidi anteriori, Stabilizzatori spalla',
    ),
    preparation: Value(
      'Siediti sulla panca con i manubri appoggiati sulle ginocchia. Datti una spinta con le gambe per portarli al petto mentre ti sdrai. Tieni i manubri sopra il petto con i palmi rivolti in avanti o semi-proni.',
    ),
    execution: Value(
      "Abbassa i manubri lateralmente con un movemento controllato, aprendo il petto fino a sentire un buon allungamento (ROM maggiore rispetto al bilanciere). Spingi i manubri verso l'alto e leggermente verso l'interno, tornando alla posizione iniziale.",
    ),
    tips: Value(
      'I manubri permettono un arco di movimento più naturale e un allungamento maggiore. Non far scontrare i manubri in cima per non perdere tensione muscolare.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Distensioni su panca inclinata (Bilanciere)'),
    targetMuscle: Value('Petto'),
    equipment: Value('Panca inclinata (30-45°), Bilanciere, Rack'),
    focusArea: Value('Pettorali (focus clavicolare/alto), Deltoidi anteriori'),
    preparation: Value(
      "Regola la panca a un'inclinazione di 30-45 gradi. Sdraiati e afferra il bilanciere con una presa media. Stacca il bilanciere e portalo sopra la parte alta del petto.",
    ),
    execution: Value(
      "Abbassa il bilanciere in modo controllato verso la parte superiore del petto (zona clavicolare). Spingi verso l'alto tornando alla posizione di partenza.",
    ),
    tips: Value(
      "Un'inclinazione eccessiva (oltre 45°) sposta gran parte del lavoro sui deltoidi anteriori. Mantieni le scapole depresse e addotte.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Distensioni su panca inclinata (Manubri)'),
    targetMuscle: Value('Petto'),
    equipment: Value('Panca inclinata (30-45°), Manubri'),
    focusArea: Value('Pettorali (focus clavicolare/alto), Deltoidi anteriori'),
    preparation: Value(
      'Come per la panca piana, porta i manubri sulle ginocchia e usa lo slancio per posizionarli sopra il petto alto mentre ti sdrai sulla panca inclinata.',
    ),
    execution: Value(
      "Abbassa i manubri ai lati del petto alto, mantenendo i gomiti sotto i polsi e non larghi. Spingi verso l'alto e leggermente verso l'interno, contraendo il petto alto.",
    ),
    tips: Value(
      "Questo esercizio è eccellente per il petto alto e permette un ottimo allungamento. Prova a ruotare leggermente i palmi verso l'interno in fase di contrazione.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Distensioni su panca declinata (Bilanciere)'),
    targetMuscle: Value('Petto'),
    equipment: Value('Panca declinata, Bilanciere, Rack'),
    focusArea: Value('Pettorali (focus addominale/basso), Tricipiti'),
    preparation: Value(
      'Posizionati sulla panca declinata assicurando i piedi o le gambe negli appositi supporti. Fatti passare il bilanciere o staccalo dal rack. Portalo sopra la parte bassa del petto.',
    ),
    execution: Value(
      "Abbassa il bilanciere controllando il movemento fino a sfiorare la parte inferiore dello sterno. Spingi con forza verso l'alto.",
    ),
    tips: Value(
      'Questo esercizio riduce lo stress sulle spalle rispetto alla panca piana o inclinata. Controlla il peso e non usare rimbalzi.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Distensioni su panca declinata (Manubri)'),
    targetMuscle: Value('Petto'),
    equipment: Value('Panca declinata, Manubri'),
    focusArea: Value('Pettorali (focus addominale/basso)'),
    preparation: Value(
      "Assicurati alla panca. Può essere difficile mettersi in posizione; tieni i manubri vicini al petto mentre ti inclini all'indietro o fatteli passare.",
    ),
    execution: Value(
      "Abbassa i manubri ai lati del petto basso. Spingi verso l'alto e leggermente verso l'interno, contraendo il petto.",
    ),
    tips: Value(
      'Simile al bilanciere ma con maggiore ROM e necessità di stabilizzazione. Ottimo per colpire le fibre basse del petto.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Croci con manubri (Panca piana)'),
    targetMuscle: Value('Petto'),
    equipment: Value('Panca piana, Manubri'),
    focusArea:
        Value('Pettorali (isolamento, focus sterno-costale, allungamento)'),
    preparation: Value(
      "Sdraiati sulla panca piana with i manubri sopra il petto, palmi rivolti l'uno verso l'altro. Mantieni i gomiti leggermente piegati (curvatura fissa) per tutto il movemento.",
    ),
    execution: Value(
      'Apri le braccia in un ampio arco, abbassando i manubri lateralmente fino a sentire un forte allungamento del petto. I gomiti devono rimanere leggermente flessi. Riporta i manubri in alto usando i pettorali, come se stessi "abbracciando un albero".',
    ),
    tips: Value(
      "Questo è un esercizio di isolamento, non di forza. Usa un peso inferiore rispetto alle distensioni e concentrati sull'allungamento e la contrazione. Non trasformarlo in una spinta.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Croci con manubri (Panca inclinata)'),
    targetMuscle: Value('Petto'),
    equipment: Value('Panca inclinata (30-45°), Manubri'),
    focusArea: Value('Pettorali (isolamento, focus clavicolare, allungamento)'),
    preparation: Value(
      'Sdraiati sulla panca inclinata, manubri sopra il petto alto, palmi che si fronteggiano, gomiti leggermente flessi.',
    ),
    execution: Value(
      "Apri le braccia lateralmente e leggermente verso il basso, mantenendo la flessione dei gomiti costante. Senti l'allungamento del petto alto. Contrai i pettorali per riportare i manubri in alto lungo un arco di cerchio.",
    ),
    tips: Value(
      "Come per le croci piane, focalizzati sull'allungamento e sulla contrazione di picco. Non estendere e flettere i gomiti durante il movemento.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Croci ai cavi alto'),
    targetMuscle: Value('Petto'),
    equipment: Value('Ercolina (Stazione cavi)'),
    focusArea: Value('Pettorali (focus addominale/basso, contrazione interna)'),
    preparation: Value(
      'Posiziona le carrucole in alto. Afferra le maniglie (o staffe) e fai un passo avanti per mettere il petto sotto tensione. Inclina leggermente il busto in avanti.',
    ),
    execution: Value(
      "Porta le maniglie verso il basso e in avanti, incrociandole idealmente davanti al bacino o alla parte bassa dell'addome. Contrai forte il petto per 1-2 secondi. Ritorna lentamente alla posizione di allungamento in modo controllato.",
    ),
    tips: Value(
      'Mantieni il busto fermo; non usare il peso del corpo per muovere il carico. La tensione è costante grazie ai cavi, sfruttala per la contrazione di picco.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Croci ai cavi basso o medio'),
    targetMuscle: Value('Petto'),
    equipment: Value('Ercolina (Stazione cavi)'),
    focusArea: Value(
      'Pettorali (focus clavicolare se dal basso, sterno-costale se medi)',
    ),
    preparation: Value(
      'Posiziona le carrucole in basso (per il petto alto) o a metà altezza (per il petto centrale). Afferra le maniglie.',
    ),
    execution: Value(
      "Se dal basso: porta le maniglie verso l'alto e in avanti, fino all'altezza degli occhi, contraendo il petto alto. Se medi: porta le maniglie orizzontalmente davanti al petto, come in un abbraccio. Ritorna lentamente.",
    ),
    tips: Value(
      "Sperimenta con l'altezza delle carrucole. La versione dal basso è eccellente per simulare le croci su panca inclinata ma con tensione continua.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Piegamenti sulle braccia (Push-ups)'),
    targetMuscle: Value('Petto'),
    equipment: Value('Corpo libero'),
    isBodyweight: Value(true),
    focusArea: Value(
      'Pettorali (sterno-costale), Tricipiti, Deltoidi anteriori, Core',
    ),
    preparation: Value(
      'Posizione di plank a braccia tese, mani leggermente più larghe delle spalle. Corpo dritto dalla testa ai talloni. Addome e glutei contratti.',
    ),
    execution: Value(
      'Abbassa il corpo in modo controllato piegando i gomiti (tenendoli a 45-60 gradi dal busto, non larghi) finché il petto non sfiora il pavimento. Spingi con forza tornando alla posizione iniziale.',
    ),
    tips: Value(
      'Non far "cadere" il bacino o "alzare" il sedere. Se è troppo difficile, inizia appoggiando le ginocchia (piegamenti facilitati) o eseguili su un rialzo (panca).',
    ),
  ),
  ExercisesCompanion(
    name: Value('Piegamenti sulle braccia declinati'),
    targetMuscle: Value('Petto'),
    equipment: Value('Corpo libero, Rialzo (panca, sedia)'),
    isBodyweight: Value(true),
    focusArea: Value(
        'Pettorali (focus clavicolare/alto), Deltoidi anteriori, Tricipiti'),
    preparation: Value(
      'Posizione di plank come i push-up, ma con i piedi appoggiati su un rialzo (panca, step o sedia stabile). Mani a terra.',
    ),
    execution: Value(
      'Abbassa il corpo finché la testa non è vicina al pavimento. Spingi tornando su. Il ROM è leggermente ridotto rispetto ai push-up classici ma il carico è maggiore.',
    ),
    tips: Value(
      'Più alto è il rialzo, maggiore è il carico sulla parte alta del petto e sulle spalle. Mantieni il core contratto per evitare di inarcare la schiena.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Dip alle parallele'),
    targetMuscle: Value('Petto'),
    equipment: Value('Parallele (o Dip station)'),
    focusArea:
        Value('Pettorali (focus basso/esterno), Tricipiti, Deltoidi anteriori'),
    preparation: Value(
      "Afferra le parallele con una presa neutra (larghezza spalle o leggermente più larga). Sostieniti a braccia tese, gambe incrociate o tese all'indietro.",
    ),
    execution: Value(
      "Inclina il busto leggermente in avanti (questo sposta il focus sul petto). Abbassati lentamente piegando i gomiti finché le spalle non sono all'altezza dei gomiti (o leggermente sotto, se la mobilità lo permette). Spingi con forza per tornare su.",
    ),
    tips: Value(
      'Se tieni il busto dritto (verticale), il focus si sposta maggiormente sui tricipiti. Scendi solo fin dove le tue spalle sono a loro agio per evitare infortuni.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Pectoral Machine(Pec Deck)'),
    targetMuscle: Value('Petto'),
    equipment: Value('Macchinario (Pec Deck / Butterfly)'),
    focusArea: Value('Pettorali (isolamento, contrazione interna)'),
    preparation: Value(
      "Siediti sulla macchina regolando l'altezza del sedile in modo che le impugnature (o i cuscinetti per gli avambracci) siano all'altezza del petto. Schiena e scapole ben appoggiate allo schienale.",
    ),
    execution: Value(
      "Chiudi le braccia davanti a te con un movemento controllato, contraendo il petto al massimo nel punto di chiusura (contrazione di picco). Ritorna lentamente alla posizione di partenza, sentendo l'allungamento.",
    ),
    tips: Value(
      "Questo è un esercizio di puro isolamento. Non usare slancio e non staccare la schiena dal supporto. Ottimo per 'pompare' il petto a fine allenamento.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Chest Press'),
    targetMuscle: Value('Petto'),
    equipment: Value('Macchinario (Chest Press)'),
    focusArea:
        Value('Pettorali (sterno-costale), Tricipiti, Deltoidi anteriori'),
    preparation: Value(
      "Regola il sedile in modo che le impugnature siano all'altezza della parte centrale del petto. Siediti con la schiena ben appoggiata e afferra le impugnature (presa prona o neutra).",
    ),
    execution: Value(
      'Spingi le impugnature in avanti fino a estendere quasi completamente le braccia, contraendo il petto. Ritorna lentamente alla posizione di partenza, controllando il peso.',
    ),
    tips: Value(
      'Simile alla panca piana ma con un movemento guidato e maggiore stabilità. Utile per principianti o per lavori ad alte ripetizioni in sicurezza.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Pullover(Manubrio)'),
    targetMuscle: Value('Petto'),
    equipment: Value('Panca piana, Manubrio'),
    focusArea:
        Value('Pettorali (allungamento), Gran Dorsale, Serrato anteriore'),
    preparation: Value(
      "Sdraiati trasversalmente sulla panca, appoggiando solo la parte alta della schiena (scapole). Tieni un manubrio con entrambe le mani (presa a 'diamante') sopra il petto. Bacino basso.",
    ),
    execution: Value(
      "Abbassa lentamente il manubrio all'indietro, oltre la testa, mantenendo i gomiti leggermente flessi. Scendi finché senti un forte allungamento del petto e del dorsale. Riporta il manubrio sopra il petto usando la forza dei muscoli pettorali e dorsali.",
    ),
    tips: Value(
      "Esercizio 'ibrido' che lavora sia petto che dorso. Concentrati sull'allungamento della cassa toracica. Mantieni il bacino basso per massimizzare lo stretch.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Svendsen Press'),
    targetMuscle: Value('Petto'),
    equipment: Value('Dischi (o due manubri piccoli)'),
    focusArea:
        Value('Pettorali (contrazione isometrica, focus interno/sterno)'),
    preparation: Value(
      "In piedi o seduto. Tieni due dischi da 2.5kg o 5kg (o due manubri leggeri) premuti l'uno contro l'altro davanti al petto. I palmi delle mani si fronteggiano, spingendo attivamente.",
    ),
    execution: Value(
      "Mantenendo la pressione costante tra i dischi/manubri, estendi lentamente le braccia davanti a te fino alla quasi completa estensione. Ritorna lentamente al petto, sempre spingendo con forza i palmi l'uno contro l'altro.",
    ),
    tips: Value(
      "Il carico è irrilevante; la tensione è creata dalla pressione isometrica che applichi. Brucerà molto nella parte interna del petto. Ottimo come 'finisher'.",
    ),
  ),
  ExercisesCompanion(
    name: Value('Landmine Press'),
    targetMuscle: Value('Petto'),
    equipment: Value('Bilanciere, Angolo (Landmine) o angolo muro'),
    focusArea: Value(
      'Pettorali (focus clavicolare/alto), Deltoidi anteriori, Stabilità core',
    ),
    preparation: Value(
      "Posiziona un'estremità del bilanciere in un supporto landmine o in un angolo sicuro. In piedi (o in ginocchio), afferra l'estremità libera del bilanciere con una mano, tenendola all'altezza della spalla/petto alto.",
    ),
    execution: Value(
      "Spingi il bilanciere verso l'alto e in avanti, seguendo l'arco naturale del movemento. Contrai il petto alto nel punto di massima estensione. Ritorna lentamente alla spalla.",
    ),
    tips: Value(
      'Ottimo per la stabilità della spalla e per chi ha fastidi con la panca inclinata. Il movemento convergente attiva molto bene il petto alto.',
    ),
  ),
  ExercisesCompanion(
    name: Value('Floor Press'),
    targetMuscle: Value('Petto'),
    equipment: Value('Pavimento, Manubri (o Bilanciere)'),
    focusArea: Value(
      'Tricipiti, Pettorali (parte alta del movemento), Deltoidi anteriori',
    ),
    preparation: Value(
      'Sdraiati sul pavimento (supino). Se usi i manubri, portali al petto. Se usi il bilanciere, posizionati sotto (richiede rack bassi o aiuto). Gambe piegate o tese.',
    ),
    execution: Value(
      "Spingi il carico verticalmente verso l'alto. Abbassa lentamente finché i tricipiti (o i gomiti) non toccano morbidamente il pavimento. Fai una breve pausa (dead-stop) e spingi di nuovo verso l'alto in modo esplosivo.",
    ),
    tips: Value(
      "Il ROM è ridotto, il che enfatizza i tricipiti e la parte finale (lockout) della spinta. Utile per rinforzare il 'lockout' della panca piana e ridurre lo stress sulle spalle.",
    ),
  ),
];
