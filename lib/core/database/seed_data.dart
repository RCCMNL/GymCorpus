import 'package:drift/drift.dart';
import 'database.dart';

/// All 157 exercises extracted from the legacy Stitch Design database.
/// Organized by muscle group: Petto, Dorso, Spalle, Bicipiti, Tricipiti,
/// Avambracci, Gambe, Polpacci, Addominali.
List<ExercisesCompanion> getSeedExercises() {
  return const [
    ExercisesCompanion(
      name: Value('Distensioni su panca piana (Bilanciere)'),
      targetMuscle: Value('Petto'),
      equipment: Value('Panca piana, Bilanciere, Rack'),
      focusArea: Value(
          'Pettorali (focus sterno-costale), Tricipiti, Deltoidi anteriori'),
      preparation: Value(
          'Sdraiati sulla panca piana. Afferra il bilanciere con una presa leggermente più larga delle spalle. Stacca il bilanciere dal rack e portalo sopra il petto a braccia tese. Mantieni le scapole addotte e depresse (assetto scapolare).'),
      execution: Value(
          'Abbassa lentamente il bilanciere fino a sfiorare la parte centrale del petto (linea dei capezzoli), mantenendo i gomiti a circa 45-60 gradi rispetto al busto. Spingi con forza il bilanciere verso l\'alto fino a tornare alla posizione iniziale, senza bloccare completamente i gomiti.'),
      tips: Value(
          'Mantieni sempre i piedi ben saldi a terra e il gluteo a contatto con la panca. Un arco lombare fisiologico è corretto e aiuta nella stabilità. Controlla la fase eccentrica (discesa).'),
    ),
    ExercisesCompanion(
      name: Value('Distensioni su panca piana (Manubri)'),
      targetMuscle: Value('Petto'),
      equipment: Value('Panca piana, Manubri'),
      focusArea: Value(
          'Pettorali (focus sterno-costale), Deltoidi anteriori, Stabilizzatori spalla'),
      preparation: Value(
          'Siediti sulla panca con i manubri appoggiati sulle ginocchia. Datti una spinta con le gambe per portarli al petto mentre ti sdrai. Tieni i manubri sopra il petto con i palmi rivolti in avanti o semi-proni.'),
      execution: Value(
          'Abbassa i manubri lateralmente con un movimento controllato, aprendo il petto fino a sentire un buon allungamento (ROM maggiore rispetto al bilanciere). Spingi i manubri verso l\'alto e leggermente verso l\'interno, tornando alla posizione iniziale.'),
      tips: Value(
          'I manubri permettono un arco di movimento più naturale e un allungamento maggiore. Non far scontrare i manubri in cima per non perdere tensione muscolare.'),
    ),
    ExercisesCompanion(
      name: Value('Distensioni su panca inclinata (Bilanciere)'),
      targetMuscle: Value('Petto'),
      equipment: Value('Panca inclinata (30-45°), Bilanciere, Rack'),
      focusArea:
          Value('Pettorali (focus clavicolare/alto), Deltoidi anteriori'),
      preparation: Value(
          'Regola la panca a un\'inclinazione di 30-45 gradi. Sdraiati e afferra il bilanciere con una presa media. Stacca il bilanciere e portalo sopra la parte alta del petto.'),
      execution: Value(
          'Abbassa il bilanciere in modo controllato verso la parte superiore del petto (zona clavicolare). Spingi verso l\'alto tornando alla posizione di partenza.'),
      tips: Value(
          'Un\'inclinazione eccessiva (oltre 45°) sposta gran parte del lavoro sui deltoidi anteriori. Mantieni le scapole depresse e addotte.'),
    ),
    ExercisesCompanion(
      name: Value('Distensioni su panca inclinata (Manubri)'),
      targetMuscle: Value('Petto'),
      equipment: Value('Panca inclinata (30-45°), Manubri'),
      focusArea:
          Value('Pettorali (focus clavicolare/alto), Deltoidi anteriori'),
      preparation: Value(
          'Come per la panca piana, porta i manubri sulle ginocchia e usa lo slancio per posizionarli sopra il petto alto mentre ti sdrai sulla panca inclinata.'),
      execution: Value(
          'Abbassa i manubri ai lati del petto alto, mantenendo i gomiti sotto i polsi e non larghi. Spingi verso l\'alto e leggermente verso l\'interno, contraendo il petto alto.'),
      tips: Value(
          'Questo esercizio è eccellente per il petto alto e permette un ottimo allungamento. Prova a ruotare leggermente i palmi verso l\'interno in fase di contrazione.'),
    ),
    ExercisesCompanion(
      name: Value('Distensioni su panca declinata (Bilanciere)'),
      targetMuscle: Value('Petto'),
      equipment: Value('Panca declinata, Bilanciere, Rack'),
      focusArea: Value('Pettorali (focus addominale/basso), Tricipiti'),
      preparation: Value(
          'Posizionati sulla panca declinata assicurando i piedi o le gambe negli appositi supporti. Fatti passare il bilanciere o staccalo dal rack. Portalo sopra la parte bassa del petto.'),
      execution: Value(
          'Abbassa il bilanciere controllando il movimento fino a sfiorare la parte inferiore dello sterno. Spingi con forza verso l\'alto.'),
      tips: Value(
          'Questo esercizio riduce lo stress sulle spalle rispetto alla panca piana o inclinata. Controlla il peso e non usare rimbalzi.'),
    ),
    ExercisesCompanion(
      name: Value('Distensioni su panca declinata (Manubri)'),
      targetMuscle: Value('Petto'),
      equipment: Value('Panca declinata, Manubri'),
      focusArea: Value('Pettorali (focus addominale/basso)'),
      preparation: Value(
          'Assicurati alla panca. Può essere difficile mettersi in posizione; tieni i manubri vicini al petto mentre ti inclini all\'indietro o fatteli passare.'),
      execution: Value(
          'Abbassa i manubri ai lati del petto basso. Spingi verso l\'alto e leggermente verso l\'interno, contraendo il petto.'),
      tips: Value(
          'Simile al bilanciere ma con maggiore ROM e necessità di stabilizzazione. Ottimo per colpire le fibre basse del petto.'),
    ),
    ExercisesCompanion(
      name: Value('Croci con manubri (Panca piana)'),
      targetMuscle: Value('Petto'),
      equipment: Value('Panca piana, Manubri'),
      focusArea:
          Value('Pettorali (isolamento, focus sterno-costale, allungamento)'),
      preparation: Value(
          'Sdraiati sulla panca piana con i manubri sopra il petto, palmi rivolti l\'uno verso l\'altro. Mantieni i gomiti leggermente piegati (curvatura fissa) per tutto il movimento.'),
      execution: Value(
          'Apri le braccia in un ampio arco, abbassando i manubri lateralmente fino a sentire un forte allungamento del petto. I gomiti devono rimanere leggermente flessi. Riporta i manubri in alto usando i pettorali, come se stessi \'abbracciando un albero\'.'),
      tips: Value(
          'Questo è un esercizio di isolamento, non di forza. Usa un peso inferiore rispetto alle distensioni e concentrati sull\'allungamento e la contrazione. Non trasformarlo in una spinta.'),
    ),
    ExercisesCompanion(
      name: Value('Croci con manubri (Panca inclinata)'),
      targetMuscle: Value('Petto'),
      equipment: Value('Panca inclinata (30-45°), Manubri'),
      focusArea:
          Value('Pettorali (isolamento, focus clavicolare, allungamento)'),
      preparation: Value(
          'Sdraiati sulla panca inclinata, manubri sopra il petto alto, palmi che si fronteggiano, gomiti leggermente flessi.'),
      execution: Value(
          'Apri le braccia lateralmente e leggermente verso il basso, mantenendo la flessione dei gomiti costante. Senti l\'allungamento del petto alto. Contrai i pettorali per riportare i manubri in alto lungo un arco di cerchio.'),
      tips: Value(
          'Come per le croci piane, focalizzati sull\'allungamento e sulla contrazione di picco. Non estendere e flettere i gomiti durante il movimento.'),
    ),
    ExercisesCompanion(
      name: Value('Croci ai cavi alto'),
      targetMuscle: Value('Petto'),
      equipment: Value('Ercolina (Stazione cavi)'),
      focusArea:
          Value('Pettorali (focus addominale/basso, contrazione interna)'),
      preparation: Value(
          'Posiziona le carrucole in alto. Afferra le maniglie (o staffe) e fai un passo avanti per mettere il petto sotto tensione. Inclina leggermente il busto in avanti.'),
      execution: Value(
          'Porta le maniglie verso il basso e in avanti, incrociandole idealmente davanti al bacino o alla parte bassa dell\'addome. Contrai forte il petto per 1-2 secondi. Ritorna lentamente alla posizione di allungamento in modo controllato.'),
      tips: Value(
          'Mantieni il busto fermo; non usare il peso del corpo per muovere il carico. La tensione è costante grazie ai cavi, sfruttala per la contrazione di picco.'),
    ),
    ExercisesCompanion(
      name: Value('Croci ai cavi basso o medio'),
      targetMuscle: Value('Petto'),
      equipment: Value('Ercolina (Stazione cavi)'),
      focusArea: Value(
          'Pettorali (focus clavicolare se dal basso, sterno-costale se medi)'),
      preparation: Value(
          'Posiziona le carrucole in basso (per il petto alto) o a metà altezza (per il petto centrale). Afferra le maniglie.'),
      execution: Value(
          'Se dal basso: porta le maniglie verso l\'alto e in avanti, fino all\'altezza degli occhi, contraendo il petto alto. Se medi: porta le maniglie orizzontalmente davanti al petto, come in un abbraccio. Ritorna lentamente.'),
      tips: Value(
          'Sperimenta con l\'altezza delle carrucole. La versione dal basso è eccellente per simulare le croci su panca inclinata ma con tensione continua.'),
    ),
    ExercisesCompanion(
      name: Value('Piegamenti sulle braccia (Push-ups)'),
      targetMuscle: Value('Petto'),
      equipment: Value('Corpo libero'),
      focusArea: Value(
          'Pettorali (sterno-costale), Tricipiti, Deltoidi anteriori, Core'),
      preparation: Value(
          'Posizione di plank a braccia tese, mani leggermente più larghe delle spalle. Corpo dritto dalla testa ai talloni. Addome e glutei contratti.'),
      execution: Value(
          'Abbassa il corpo in modo controllato piegando i gomiti (tenendoli a 45-60 gradi dal busto, non larghi) finché il petto non sfiora il pavimento. Spingi con forza tornando alla posizione iniziale.'),
      tips: Value(
          'Non far \'cadere\' il bacino o \'alzare\' il sedere. Se è troppo difficile, inizia appoggiando le ginocchia (piegamenti facilitati) o eseguili su un rialzo (panca).'),
    ),
    ExercisesCompanion(
      name: Value('Piegamenti sulle braccia declinati'),
      targetMuscle: Value('Petto'),
      equipment: Value('Corpo libero, Rialzo (panca, sedia)'),
      focusArea: Value(
          'Pettorali (focus clavicolare/alto), Deltoidi anteriori, Tricipiti'),
      preparation: Value(
          'Posizione di plank come i push-up, ma con i piedi appoggiati su un rialzo (panca, step o sedia stabile). Mani a terra.'),
      execution: Value(
          'Abbassa il corpo finché la testa non è vicina al pavimento. Spingi tornando su. Il ROM è leggermente ridotto rispetto ai push-up classici ma il carico è maggiore.'),
      tips: Value(
          'Più alto è il rialzo, maggiore è il carico sulla parte alta del petto e sulle spalle. Mantieni il core contratto per evitare di inarcare la schiena.'),
    ),
    ExercisesCompanion(
      name: Value('Dip alle parallele'),
      targetMuscle: Value('Petto'),
      equipment: Value('Parallele (o Dip station)'),
      focusArea: Value(
          'Pettorali (focus basso/esterno), Tricipiti, Deltoidi anteriori'),
      preparation: Value(
          'Afferra le parallele con una presa neutra (larghezza spalle o leggermente più larga). Sostieniti a braccia tese, gambe incrociate o tese all\'indietro.'),
      execution: Value(
          'Inclina il busto leggermente in avanti (questo sposta il focus sul petto). Abbassati lentamente piegando i gomiti finché le spalle non sono all\'altezza dei gomiti (o leggermente sotto, se la mobilità lo permette). Spingi con forza per tornare su.'),
      tips: Value(
          'Se tieni il busto dritto (verticale), il focus si sposta maggiormente sui tricipiti. Scendi solo fin dove le tue spalle sono a loro agio per evitare infortuni.'),
    ),
    ExercisesCompanion(
      name: Value('Pectoral Machine(Pec Deck)'),
      targetMuscle: Value('Petto'),
      equipment: Value('Macchinario (Pec Deck / Butterfly)'),
      focusArea: Value('Pettorali (isolamento, contrazione interna)'),
      preparation: Value(
          'Siediti sulla macchina regolando l\'altezza del sedile in modo che le impugnature (o i cuscinetti per gli avambracci) siano all\'altezza del petto. Schiena e scapole ben appoggiate allo schienale.'),
      execution: Value(
          'Chiudi le braccia davanti a te con un movimento controllato, contraendo il petto al massimo nel punto di chiusura (contrazione di picco). Ritorna lentamente alla posizione di partenza, sentendo l\'allungamento.'),
      tips: Value(
          'Questo è un esercizio di puro isolamento. Non usare slancio e non staccare la schiena dal supporto. Ottimo per \'pompare\' il petto a fine allenamento.'),
    ),
    ExercisesCompanion(
      name: Value('Chest Press'),
      targetMuscle: Value('Petto'),
      equipment: Value('Macchinario (Chest Press)'),
      focusArea:
          Value('Pettorali (sterno-costale), Tricipiti, Deltoidi anteriori'),
      preparation: Value(
          'Regola il sedile in modo che le impugnature siano all\'altezza della parte centrale del petto. Siediti con la schiena ben appoggiata e afferra le impugnature (presa prona o neutra).'),
      execution: Value(
          'Spingi le impugnature in avanti fino a estendere quasi completamente le braccia, contraendo il petto. Ritorna lentamente alla posizione di partenza, controllando il peso.'),
      tips: Value(
          'Simile alla panca piana ma con un movimento guidato e maggiore stabilità. Utile per principianti o per lavori ad alte ripetizioni in sicurezza.'),
    ),
    ExercisesCompanion(
      name: Value('Pullover(Manubrio)'),
      targetMuscle: Value('Petto'),
      equipment: Value('Panca piana, Manubrio'),
      focusArea:
          Value('Pettorali (allungamento), Gran Dorsale, Serrato anteriore'),
      preparation: Value(
          'Sdraiati trasversalmente sulla panca, appoggiando solo la parte alta della schiena (scapole). Tieni un manubrio con entrambe le mani (presa a \'diamante\') sopra il petto. Bacino basso.'),
      execution: Value(
          'Abbassa lentamente il manubrio all\'indietro, oltre la testa, mantenendo i gomiti leggermente flessi. Scendi finché senti un forte allungamento del petto e del dorsale. Riporta il manubrio sopra il petto usando la forza dei muscoli pettorali e dorsali.'),
      tips: Value(
          'Esercizio \'ibrido\' che lavora sia petto che dorso. Concentrati sull\'allungamento della cassa toracica. Mantieni il bacino basso per massimizzare lo stretch.'),
    ),
    ExercisesCompanion(
      name: Value('Svendsen Press'),
      targetMuscle: Value('Petto'),
      equipment: Value('Dischi (o due manubri piccoli)'),
      focusArea:
          Value('Pettorali (contrazione isometrica, focus interno/sterno)'),
      preparation: Value(
          'In piedi o seduto. Tieni due dischi da 2.5kg o 5kg (o due manubri leggeri) premuti l\'uno contro l\'altro davanti al petto. I palmi delle mani si fronteggiano, spingendo attivamente.'),
      execution: Value(
          'Mantenendo la pressione costante tra i dischi/manubri, estendi lentamente le braccia davanti a te fino alla quasi completa estensione. Ritorna lentamente al petto, sempre spingendo con forza i palmi l\'uno contro l\'altro.'),
      tips: Value(
          'Il carico è irrilevante; la tensione è creata dalla pressione isometrica che applichi. Brucerà molto nella parte interna del petto. Ottimo come \'finisher\'.'),
    ),
    ExercisesCompanion(
      name: Value('Landmine Press'),
      targetMuscle: Value('Petto'),
      equipment: Value('Bilanciere, Angolo (Landmine) o angolo muro'),
      focusArea: Value(
          'Pettorali (focus clavicolare/alto), Deltoidi anteriori, Stabilità core'),
      preparation: Value(
          'Posiziona un\'estremità del bilanciere in un supporto landmine o in un angolo sicuro. In piedi (o in ginocchio), afferra l\'estremità libera del bilanciere con una mano, tenendola all\'altezza della spalla/petto alto.'),
      execution: Value(
          'Spingi il bilanciere verso l\'alto e in avanti, seguendo l\'arco naturale del movimento. Contrai il petto alto nel punto di massima estensione. Ritorna lentamente alla spalla.'),
      tips: Value(
          'Ottimo per la stabilità della spalla e per chi ha fastidi con la panca inclinata. Il movimento convergente attiva molto bene il petto alto.'),
    ),
    ExercisesCompanion(
      name: Value('Floor Press'),
      targetMuscle: Value('Petto'),
      equipment: Value('Pavimento, Manubri (o Bilanciere)'),
      focusArea: Value(
          'Tricipiti, Pettorali (parte alta del movimento), Deltoidi anteriori'),
      preparation: Value(
          'Sdraiati sul pavimento (supino). Se usi i manubri, portali al petto. Se usi il bilanciere, posizionati sotto (richiede rack bassi o aiuto). Gambe piegate o tese.'),
      execution: Value(
          'Spingi il carico verticalmente verso l\'alto. Abbassa lentamente finché i tricipiti (o i gomiti) non toccano morbidamente il pavimento. Fai una breve pausa (dead-stop) e spingi di nuovo verso l\'alto in modo esplosivo.'),
      tips: Value(
          'Il ROM è ridotto, il che enfatizza i tricipiti e la parte finale (lockout) della spinta. Utile per rinforzare il \'lockout\' della panca piana e ridurre lo stress sulle spalle.'),
    ),
    ExercisesCompanion(
      name: Value('Pull-ups (presa prona larga)'),
      targetMuscle: Value('Dorso'),
      equipment: Value('Sbarra per trazioni'),
      focusArea: Value('Gran dorsale (ampiezza), Bicipiti, Romboidi'),
      preparation: Value(
          'Afferra la sbarra con una presa prona (palmi lontani da te) molto più larga delle spalle. Parti da una posizione appesa (dead hang), braccia tese.'),
      execution: Value(
          'Tira il corpo verso l\'alto, guidando il movimento con i gomiti che spingono verso il basso e all\'indietro. Cerca di portare il petto alla sbarra. Scendi in modo controllato fino alla completa estensione.'),
      tips: Value(
          'Focalizzati sul \'tirare\' con i muscoli della schiena, non solo con le braccia. Deprimi le scapole prima di iniziare la trazione. Non dondolare.'),
    ),
    ExercisesCompanion(
      name: Value('Chin-ups (presa supina)'),
      targetMuscle: Value('Dorso'),
      equipment: Value('Sbarra per trazioni'),
      focusArea: Value('Bicipiti, Gran dorsale (parte bassa), Romboidi'),
      preparation: Value(
          'Afferra la sbarra con una presa supina (palmi verso di te) larghezza spalle.'),
      execution: Value(
          'Tira il corpo verso l\'alto fino a superare la sbarra con il mento. Il focus si sposta maggiormente sui bicipiti rispetto alla presa prona. Scendi controllato.'),
      tips: Value(
          'Esercizio eccellente per bicipiti e dorso. Spesso si riesce a fare più ripetizioni o con più carico rispetto ai pull-up.'),
    ),
    ExercisesCompanion(
      name: Value('Trazioni alla sbarra (presa neutra)'),
      targetMuscle: Value('Dorso'),
      equipment: Value('Sbarra per trazioni (con maniglie parallele / V-Bar)'),
      focusArea: Value('Gran dorsale, Bicipiti, Brachioradiale'),
      preparation: Value(
          'Afferra le maniglie parallele (presa neutra o \'a martello\'). Parti da appeso.'),
      execution: Value(
          'Tira il corpo verso l\'alto, mantenendo i gomiti vicini al corpo. Questa presa è spesso la più confortevole per le articolazioni di polsi e spalle.'),
      tips: Value(
          'Permette un ottimo equilibrio tra il lavoro del dorsale e quello delle braccia (bicipiti e brachiali).'),
    ),
    ExercisesCompanion(
      name: Value('Lat Machine (presa larga)'),
      targetMuscle: Value('Dorso'),
      equipment: Value('Macchinario (Lat Machine), Barra lunga'),
      focusArea: Value('Gran dorsale (ampiezza)'),
      preparation: Value(
          'Siediti alla macchina, blocca le ginocchia sotto i cuscinetti. Afferra la barra con presa prona larga (come i pull-up).'),
      execution: Value(
          'Tira la barra verso la parte alta del petto, guidando con i gomiti. Contrai la schiena (adduzione scapolare) in basso. Ritorna lentamente, controllando l\'eccentrica fino alla quasi estensione.'),
      tips: Value(
          'Non usare lo slancio del busto. Pensa a \'tirare\' con i gomiti verso i fianchi. Mantieni il petto \'alto\'.'),
    ),
    ExercisesCompanion(
      name: Value('Lat Machine (presa stretta)'),
      targetMuscle: Value('Dorso'),
      equipment: Value('Macchinario (Lat Machine), Barra (o maniglia stretta)'),
      focusArea: Value('Gran dorsale (parte bassa/interna), Bicipiti'),
      preparation: Value(
          'Siediti alla macchina. Afferra la barra con presa supina (palmi verso di te) larghezza spalle o più stretta.'),
      execution: Value(
          'Tira la barra verso il petto, con un arco di movimento simile ai chin-up. Contrai forte bicipiti e dorsali. Ritorna controllato.'),
      tips: Value(
          'Permette di caricare molto e coinvolge intensamente i bicipiti.'),
    ),
    ExercisesCompanion(
      name: Value('Lat Machine (Presa neutra/ V-Bar)'),
      targetMuscle: Value('Dorso'),
      equipment:
          Value('Macchinario (Lat Machine), V-Bar (maniglia stretta neutra)'),
      focusArea: Value('Gran dorsale, Romboidi'),
      preparation:
          Value('Siediti alla macchina. Aggancia la V-Bar e afferrala.'),
      execution: Value(
          'Tira la maniglia verso il petto. La presa stretta e neutra permette un ottimo allungamento in alto e una forte contrazione in basso.'),
      tips: Value(
          'Molto efficace per colpire la parte \'interna\' della schiena.'),
    ),
    ExercisesCompanion(
      name: Value('Rematore con bilanciere'),
      targetMuscle: Value('Dorso'),
      equipment: Value('Bilanciere, Pesi'),
      focusArea: Value(
          'Gran dorsale (spessore), Romboidi, Trapezio, Erettori spinali (isom.)'),
      preparation: Value(
          'Parti con il bilanciere a terra. Piegati in avanti (hip hinge) fino a che il busto è quasi parallelo al suolo (45-70 gradi). Schiena piatta e tesa! Afferra il bilanciere (presa prona o supina).'),
      execution: Value(
          'Tira il bilanciere verso la parte bassa del petto o l\'addome, contraendo la schiena e guidando con i gomiti. Ritorna controllato senza poggiare a terra (o poggia per il Pendlay).'),
      tips: Value(
          'La schiena deve rimanere bloccata e piatta per tutto il tempo. La presa supina coinvolge più i bicipiti.'),
    ),
    ExercisesCompanion(
      name: Value('Rematore Pendlay'),
      targetMuscle: Value('Dorso'),
      equipment: Value('Bilanciere, Pesi'),
      focusArea: Value('Dorsali, Trapezio, Schiena (superiore), Erettori'),
      preparation: Value(
          'Parti come un rematore bilanciere, ma il busto DEVE essere parallelo al suolo. Il bilanciere parte da terra ad ogni ripetizione.'),
      execution: Value(
          'Tira il bilanciere esplosivamente verso lo sterno/petto alto. Contrai. Riporta il bilanciere a terra (dead-stop) e ripeti.'),
      tips: Value(
          'Costruisce potenza nella schiena. Elimina lo slancio e lo stress sulla lombare (se eseguito correttamente) perché ogni rep parte da fermo.'),
    ),
    ExercisesCompanion(
      name: Value('Rematore con manubrio'),
      targetMuscle: Value('Dorso'),
      equipment: Value('Manubrio, Panca piana'),
      focusArea: Value('Gran dorsale, Romboidi, Bicipiti (lavoro unilaterale)'),
      preparation: Value(
          'Appoggia un ginocchio e la mano dello stesso lato su una panca piana. Busto parallelo a terra. Afferra il manubrio con l\'altra mano, braccio teso.'),
      execution: Value(
          'Tira il manubrio verso il fianco (non verso il petto), seguendo un arco di movimento naturale (\'avviando una motosega\'). Contrai il dorsale. Ritorna lentamente in allungamento.'),
      tips: Value(
          'Il lavoro unilaterale permette un ROM maggiore e corregge squilibri. Non ruotare il busto.'),
    ),
    ExercisesCompanion(
      name: Value('Rematore al T-Bar'),
      targetMuscle: Value('Dorso'),
      equipment: Value('Bilanciere (angolo landmine) o Macchina T-Bar'),
      focusArea: Value('Dorso (spessore, parte centrale), Trapezio, Romboidi'),
      preparation: Value(
          'Posiziona un\'estremità del bilanciere in un angolo (landmine). Carica l\'altra estremità. Mettiti a cavalcioni e afferra il bilanciere (con V-Bar o presa diretta). Busto flesso a 45°.'),
      execution: Value(
          'Tira il peso verso il petto, contraendo la schiena. Scendi controllato.'),
      tips: Value(
          'Molto simile al rematore bilanciere, ma l\'arco di movimento è fisso e permette di caricare molto peso.'),
    ),
    ExercisesCompanion(
      name: Value('Rematore al cavo basso (Seated Cable Row)'),
      targetMuscle: Value('Dorso'),
      equipment: Value('Macchinario (Pulley), Maniglia (stretta o larga)'),
      focusArea: Value('Dorso (spessore), Romboidi, Trapezio (medio)'),
      preparation: Value(
          'Siediti alla macchina, piedi sugli appoggi, ginocchia leggermente flesse. Afferra la maniglia (es. V-Bar stretta). Schiena dritta.'),
      execution: Value(
          'Tira la maniglia verso l\'addome, mantenendo il busto eretto (non dondolare). Tira le scapole indietro e contrai. Ritorna controllato, allungando bene la schiena in avanti (ma senza curvarla).'),
      tips: Value(
          'Presa stretta = più romboidi/spessore. Presa larga = più dorsali/ampiezza.'),
    ),
    ExercisesCompanion(
      name: Value('Rematore con petto in appoggio'),
      targetMuscle: Value('Dorso'),
      equipment: Value('Panca inclinata (30-45°), Manubri (o Bilanciere)'),
      focusArea: Value('Dorso (superiore), Romboidi, Trapezio (isolamento)'),
      preparation: Value(
          'Sdraiati prono (faccia in giù) su una panca inclinata, petto appoggiato. Afferra i manubri.'),
      execution: Value(
          'Tira i manubri verso l\'alto, guidando con i gomiti e contraendo le scapole. Il petto rimane sempre appoggiato.'),
      tips: Value(
          'Isola perfettamente i muscoli della schiena eliminando qualsiasi stress lombare o slancio.'),
    ),
    ExercisesCompanion(
      name: Value('Stacco da terra (Deadlift) '),
      targetMuscle: Value('Dorso'),
      equipment: Value('Bilanciere, Pesi'),
      focusArea: Value(
          'Catena posteriore totale, Erettori spinali, Trapezio, Glutei, Ischiocrurali'),
      preparation: Value(
          'Piedi larghezza fianchi sotto il bilanciere. Afferra il bilanciere appena fuori dalle ginocchia. Schiena piatta e tesa, petto in fuori, bacino basso.'),
      execution: Value(
          'Spingi con le gambe \'allontanando il pavimento\'. Estendi l\'anca quando il bilanciere supera le ginocchia. Contrai glutei e schiena in cima. Scendi in modo controllato.'),
      tips: Value(
          'Esercizio fondamentale per la forza di tutto il corpo. La schiena lavora isometricamente per mantenere la posizione: cruciale per lo spessore (erettori, trapezi).'),
    ),
    ExercisesCompanion(
      name: Value('Stacco Romeno'),
      targetMuscle: Value('Dorso'),
      equipment: Value('Bilanciere o Manubri'),
      focusArea: Value('Ischiocrurali, Glutei, Erettori spinali (isom.)'),
      preparation: Value(
          'Parti in piedi con il bilanciere/manubri in mano. Gambe leggermente piegate (ma fisse).'),
      execution: Value(
          'Spingi il bacino indietro (hip hinge), mantenendo la schiena piatta e il bilanciere vicino alle gambe. Scendi finché senti allungamento. Torna su estendendo l\'anca.'),
      tips: Value(
          'Sebbene il focus primario siano gli ischiocrurali, gli erettori spinali lavorano intensamente in isometrica per stabilizzare la colonna.'),
    ),
    ExercisesCompanion(
      name: Value('Hyperextensions'),
      targetMuscle: Value('Dorso'),
      equipment: Value('Panca 45° (Hyperextension) o GHD'),
      focusArea:
          Value('Erettori spinali (zona lombare), Glutei, Ischiocrurali'),
      preparation: Value(
          'Posizionati sulla panca 45°, caviglie bloccate, bacino sul bordo del pad. Incrocia le braccia al petto (o mani dietro la testa/peso).'),
      execution: Value(
          'Fletti il busto scendendo verso il basso (mantenendo la schiena piatta). Risali usando gli erettori spinali e i glutei, fino a formare una linea retta (non iperestendere!).'),
      tips: Value(
          'Ottimo per rinforzare la parte bassa della schiena. Puoi tenere un disco al petto per aumentare il carico.'),
    ),
    ExercisesCompanion(
      name: Value('Pulldown a braccia tese'),
      targetMuscle: Value('Dorso'),
      equipment: Value('Cavo (Ercolina), Barra (dritta o corda)'),
      focusArea: Value('Gran dorsale (isolamento), Core'),
      preparation: Value(
          'Posiziona la carrucola in alto. Afferra la barra (presa prona). Fai un passo indietro, busto leggermente flesso in avanti, braccia quasi tese.'),
      execution: Value(
          'Mantenendo le braccia tese, tira la barra verso le cosce con un ampio arco di movimento, contraendo i dorsali. Ritorna lentamente.'),
      tips: Value(
          'Esercizio di isolamento puro per i dorsali. Non piegare i gomiti (non è un pushdown per tricipiti).'),
    ),
    ExercisesCompanion(
      name: Value('Pullover'),
      targetMuscle: Value('Dorso'),
      equipment: Value('Manubrio, Panca piana'),
      focusArea: Value('Gran dorsale (allungamento), Petto, Serrato anteriore'),
      preparation: Value(
          'Appoggia solo la parte alta della schiena (scapole) di traverso su una panca piana. Piedi a terra, bacino basso. Tieni un manubrio \'a coppa\' sopra il petto.'),
      execution: Value(
          'Abbassa il manubrio all\'indietro (oltre la testa) con i gomiti leggermente flessi, sentendo un forte allungamento del dorsale e del petto. Ritorna alla posizione iniziale.'),
      tips: Value(
          'Esercizio \'vecchia scuola\' per l\'espansione della cassa toracica e l\'allungamento del gran dorsale.'),
    ),
    ExercisesCompanion(
      name: Value('Rematore inverso'),
      targetMuscle: Value('Dorso'),
      equipment: Value('Sbarra (bassa, es. Multipower) o Anelli/TRX'),
      focusArea: Value('Dorso (superiore), Romboidi, Bicipiti (corpo libero)'),
      preparation: Value(
          'Posiziona una sbarra ad altezza bacino. Mettiti sotto (sdraiato supino), afferra la sbarra (presa prona o supina). Corpo teso (come un plank inverso), talloni a terra.'),
      execution: Value(
          'Tira il petto verso la sbarra, contraendo la schiena. Scendi controllato.'),
      tips: Value(
          'Ottimo esercizio a corpo libero. Più sei orizzontale, più è difficile. Tieni il corpo dritto (non far cadere il bacino).'),
    ),
    ExercisesCompanion(
      name: Value('Scrollate con manubri/bilanciere'),
      targetMuscle: Value('Dorso'),
      equipment: Value('Manubri (pesanti) o Bilanciere'),
      focusArea: Value('Trapezio (superiore)'),
      preparation: Value(
          'In piedi, tieni i manubri pesanti ai lati (o bilanciere davanti).'),
      execution: Value(
          'Solleva (\'scrolla\') le spalle verticalmente verso le orecchie, senza piegare i gomiti. Contrai il trapezio in cima per 1-2 secondi. Ritorna lentamente.'),
      tips: Value(
          'Il trapezio è un muscolo importante della schiena. Non ruotare le spalle; il movimento è solo verticale.'),
    ),
    ExercisesCompanion(
      name: Value('Face Pull'),
      targetMuscle: Value('Dorso'),
      equipment: Value('Cavo (Ercolina), Corda'),
      focusArea: Value(
          'Trapezio (medio e basso), Deltoidi posteriori, Cuffia rotatori'),
      preparation: Value(
          'Posiziona la carrucola all\'altezza degli occhi. Afferra la corda (presa prona). Fai un passo indietro.'),
      execution: Value(
          'Tira la corda verso il viso (\'pull\'), puntando ai lati della testa. Contemporaneamente, ruota esternamente le spalle (extrarotazione). Contrai forte la parte alta della schiena.'),
      tips: Value(
          'Fondamentale per la salute delle spalle e per bilanciare tutto il lavoro di spinta. Lavora la parte alta del dorso (trapezi/romboidi).'),
    ),
    ExercisesCompanion(
      name: Value('Overhead Press con bilanciere'),
      targetMuscle: Value('Spalle'),
      equipment: Value('Bilanciere, Rack (opzionale)'),
      focusArea: Value('Deltoidi (anteriori, mediali), Tricipiti, Trapezio'),
      preparation: Value(
          'In piedi, afferra il bilanciere con presa prona (palmi avanti) leggermente più larga delle spalle. Porta il bilanciere al petto alto/clavicole (puoi staccarlo da un rack). Core contratto, glutei contratti.'),
      execution: Value(
          'Spingi il bilanciere verticalmente sopra la testa fino alla completa estensione delle braccia, senza iperestendere la schiena. Il bilanciere termina sopra la nuca. Scendi in modo controllato tornando alla posizione iniziale.'),
      tips: Value(
          'Mantieni l\'addome contratto per evitare di inarcare la schiena. Pensa a \'infilare la testa sotto\' il bilanciere nella fase finale.'),
    ),
    ExercisesCompanion(
      name: Value('Overhead Press con manubri'),
      targetMuscle: Value('Spalle'),
      equipment: Value('Manubri, Panca (se seduto)'),
      focusArea:
          Value('Deltoidi (anteriori, mediali), Tricipiti, Stabilizzatori'),
      preparation: Value(
          'Seduto su panca con schienale a 90° o in piedi. Porta i manubri all\'altezza delle spalle, palmi rivolti in avanti (o semi-proni per più comfort).'),
      execution: Value(
          'Spingi i manubri verticalmente sopra la testa, convergendo leggermente in cima senza farli toccare. Ritorna lentamente alla posizione di partenza (gomiti a 90 gradi o leggermente sotto).'),
      tips: Value(
          'I manubri permettono un ROM più naturale rispetto al bilanciere. La versione seduta isola di più le spalle.'),
    ),
    ExercisesCompanion(
      name: Value('Arnold Press'),
      targetMuscle: Value('Spalle'),
      equipment: Value('Manubri, Panca (consigliata)'),
      focusArea: Value('Deltoidi (tutti i capi, focus anteriore e mediale)'),
      preparation: Value(
          'Seduto su panca. Parti con i manubri davanti al petto, palmi rivolti verso di te (presa supina).'),
      execution: Value(
          'Inizia spingendo verso l\'alto. Mentre sali, ruota i polsi in modo che i palmi guardino in avanti nella parte finale del movimento (come una OHP con manubri). Inverti il movimento in discesa, tornando alla posizione supina iniziale.'),
      tips: Value(
          'Movimento fluido e controllato, non a scatti. Combina una spinta con una rotazione, lavorando i capi del deltoide in modi diversi.'),
    ),
    ExercisesCompanion(
      name: Value('Alzate laterali(Manubri)'),
      targetMuscle: Value('Spalle'),
      equipment: Value('Manubri'),
      focusArea: Value('Deltoidi (mediali/laterali)'),
      preparation: Value(
          'In piedi (o seduto), manubri ai lati del corpo, palmi rivolti verso i fianchi. Ginocchia e gomiti leggermente flessi.'),
      execution: Value(
          'Solleva i manubri lateralmente fino all\'altezza delle spalle. Pensa a \'spingere\' i manubri verso le pareti laterali, non a \'tirarli\' su. Il mignolo dovrebbe essere idealmente alla stessa altezza (o leggermente più su) del pollice.'),
      tips: Value(
          'Esercizio di isolamento. Non usare slancio (cheating) e non superare l\'altezza delle spalle. Mantieni il busto fermo.'),
    ),
    ExercisesCompanion(
      name: Value('Alzate laterali ai cavi'),
      targetMuscle: Value('Spalle'),
      equipment: Value('Cavo (Ercolina), Maniglia'),
      focusArea: Value('Deltoidi (mediali, tensione costante)'),
      preparation: Value(
          'Posiziona la carrucola in basso. Afferra la maniglia con la mano opposta al cavo (es. mano dx, cavo a sx). Fai un passo laterale per mettere in tensione.'),
      execution: Value(
          'Esegui un\'alzata laterale come con i manubri. Il cavo offre una tensione costante per tutto l\'arco di movimento, specialmente in basso.'),
      tips: Value(
          'Puoi tenerti a un supporto con l\'altra mano per stabilizzare il corpo. Concentrati sul deltoide mediale.'),
    ),
    ExercisesCompanion(
      name: Value('Alzate frontali'),
      targetMuscle: Value('Spalle'),
      equipment: Value('Manubri'),
      focusArea: Value('Deltoidi (anteriori)'),
      preparation: Value(
          'In piedi, manubri davanti alle cosce, palmi rivolti verso il corpo (presa prona).'),
      execution: Value(
          'Solleva un manubrio (o entrambi) dritto davanti a te fino all\'altezza degli occhi/spalle. Mantieni il braccio quasi teso (leggera flessione gomito). Ritorna controllato. Alterna le braccia o eseguile insieme.'),
      tips: Value(
          'Evita di usare slancio o di inarcare la schiena. Il deltoide anteriore è già molto stimolato dalle spinte (es. panca piana, OHP).'),
    ),
    ExercisesCompanion(
      name: Value('Alzate frontali'),
      targetMuscle: Value('Spalle'),
      equipment: Value('Disco (bumper/ghisa) o Bilanciere (dritto o EZ)'),
      focusArea: Value('Deltoidi (anteriori)'),
      preparation: Value(
          'Afferra un disco ai lati (\'presa volante\') o un bilanciere con presa larghezza spalle.'),
      execution: Value(
          'Solleva l\'attrezzo davanti a te fino all\'altezza delle spalle/occhi. Mantieni il core contratto per stabilizzare.'),
      tips: Value(
          'Simile ai manubri, ma il bilanciere richiede più stabilizzazione e il disco offre una presa diversa.'),
    ),
    ExercisesCompanion(
      name: Value('Alzate posteriori a 90'),
      targetMuscle: Value('Spalle'),
      equipment: Value('Manubri, Panca (opzionale)'),
      focusArea: Value('Deltoidi (posteriori), Romboidi, Trapezio (medio)'),
      preparation: Value(
          'In piedi, piega il busto in avanti a 90° (schiena piatta!) o siediti sul bordo di una panca e piegati in avanti. Tieni i manubri sotto il petto, palmi che si fronteggiano.'),
      execution: Value(
          'Solleva i manubri lateralmente (come un uccello che apre le ali), mantenendo i gomiti leggermente flessi. Contrai le scapole in cima. Ritorna controllato.'),
      tips: Value(
          'Non tirare con la schiena, il movimento parte dalle spalle. Usa pesi leggeri e concentrati sulla contrazione dei deltoidi posteriori.'),
    ),
    ExercisesCompanion(
      name: Value('Alzate posteriori ai cavi'),
      targetMuscle: Value('Spalle'),
      equipment: Value('Cavi (Ercolina)'),
      focusArea: Value('Deltoidi (posteriori), Romboidi'),
      preparation: Value(
          'Posiziona le carrucole a metà altezza o alte. Afferra le maniglie incrociandole (cavo dx con mano sx, cavo sx con mano dx). Fai un passo indietro.'),
      execution: Value(
          'Apri le braccia (\'tira\') lateralmente e all\'indietro, mantenendo le braccia quasi tese. Contrai i deltoidi posteriori. Ritorna lentamente.'),
      tips: Value(
          'Tensione costante ottima per l\'isolamento dei deltoidi posteriori. Mantieni il petto \'in fuori\' e la schiena dritta.'),
    ),
    ExercisesCompanion(
      name: Value('Face Pull'),
      targetMuscle: Value('Spalle'),
      equipment: Value('Cavo (Ercolina), Corda'),
      focusArea:
          Value('Deltoidi (posteriori), Cuffia dei rotatori, Trapezio (medio)'),
      preparation: Value(
          'Posiziona la carrucola all\'altezza degli occhi o del petto. Afferra la corda con presa prona (pollici verso di te). Fai un passo indietro.'),
      execution: Value(
          'Tira la corda verso il viso (\'pull\'), puntando ai lati della testa (altezza orecchie/occhi). Contemporaneamente, ruota esternamente le spalle (extrarotazione). Contrai forte in cima.'),
      tips: Value(
          'Fondamentale per la salute delle spalle. Non usare troppo peso. Il focus è sulla contrazione posteriore e sull\'extrarotazione.'),
    ),
    ExercisesCompanion(
      name: Value('Tirate al mento con bilanciere'),
      targetMuscle: Value('Spalle'),
      equipment: Value('Bilanciere'),
      focusArea: Value('Deltoidi (mediali), Trapezio'),
      preparation: Value(
          'Afferra il bilanciere con una presa larga (più larga delle spalle). Parti con il bilanciere alle cosce.'),
      execution: Value(
          'Tira il bilanciere verso l\'alto lungo il corpo, guidando il movimento con i gomiti (i gomiti salgono alti e larghi). Fermati quando il bilanciere arriva al petto (non al mento).'),
      tips: Value(
          'La presa larga è fondamentale per focalizzarsi sui deltoidi mediali e ridurre l\'impingement (schiacciamento) della spalla, a differenza della presa stretta.'),
    ),
    ExercisesCompanion(
      name: Value('Tirate al mento (Manubri)'),
      targetMuscle: Value('Spalle'),
      equipment: Value('Manubri'),
      focusArea: Value('Deltoidi (mediali), Trapezio'),
      preparation:
          Value('Tieni i manubri davanti a te (palmi verso il corpo).'),
      execution: Value(
          'Tira i manubri verso l\'alto, guidando con i gomiti. I manubri permettono un movimento più libero rispetto al bilanciere, potenzialmente più sicuro per le spalle.'),
      tips: Value(
          'Come per il bilanciere, guida con i gomiti e non portare i pesi troppo in alto (altezza petto va bene).'),
    ),
    ExercisesCompanion(
      name: Value('Neck Press)'),
      targetMuscle: Value('Spalle'),
      equipment: Value('Bilanciere, Rack'),
      focusArea: Value('Deltoidi (mediali, anteriori), Tricipiti'),
      preparation: Value(
          'Posiziona il bilanciere sulla nuca/trapezi (come uno squat). Presa larga.'),
      execution: Value(
          'Spingi il bilanciere verticalmente sopra la testa. Scendi controllato tornando dietro la nuca.'),
      tips: Value(
          'ATTENZIONE: Richiede un\'ottima mobilità delle spalle (extrarotazione) e toracica. Molte persone non hanno la mobilità per eseguirlo in sicurezza. Procedere con cautela e pesi bassi.'),
    ),
    ExercisesCompanion(
      name: Value('Push Press'),
      targetMuscle: Value('Spalle'),
      equipment: Value('Bilanciere, Rack'),
      focusArea: Value('Spalle (potenza), Deltoidi, Tricipiti, Gambe (spinta)'),
      preparation: Value(
          'Posizione di partenza come una OHP (bilanciere sulle clavicole).'),
      execution: Value(
          'Esegui un rapido \'dip\' (mini-squat) piegando leggermente le ginocchia. Immediatamente, spingi con forza con le gambe e contemporaneamente spingi il bilanciere sopra la testa in modo esplosivo.'),
      tips: Value(
          'È un movimento di potenza, non di ipertrofia pura. Usa lo slancio (leg drive) delle gambe per muovere più carico. Scendi in modo controllato (eccentrica).'),
    ),
    ExercisesCompanion(
      name: Value('Reverse Pec Deck'),
      targetMuscle: Value('Spalle'),
      equipment: Value('Macchinario (Pec Deck / Rear Delt)'),
      focusArea: Value('Deltoidi (posteriori)'),
      preparation: Value(
          'Siediti sulla macchina al contrario (faccia verso lo schienale). Regola il sedile. Afferra le impugnature (presa prona o neutra).'),
      execution: Value(
          'Apri le braccia all\'indietro, mantenendole quasi tese. Contrai i deltoidi posteriori. Ritorna lentamente.'),
      tips: Value(
          'Puro isolamento per i deltoidi posteriori. Non usare slancio e concentrati sulla contrazione di picco.'),
    ),
    ExercisesCompanion(
      name: Value('Landmine Press'),
      targetMuscle: Value('Spalle'),
      equipment: Value('Bilanciere, Supporto Landmine'),
      focusArea:
          Value('Deltoide (anteriore), Pettorale (clavicolare), Tricipiti'),
      preparation: Value(
          'In ginocchio o in piedi. Afferra l\'estremità libera del bilanciere con una mano all\'altezza della spalla.'),
      execution: Value(
          'Spingi il bilanciere verso l\'alto e in avanti, estendendo il braccio. Contrai spalla e petto alto. Ritorna controllato.'),
      tips: Value(
          'Movimento unilaterale che segue un arco naturale, spesso più confortevole per le spalle rispetto alla OHP verticale.'),
    ),
    ExercisesCompanion(
      name: Value('Pike Push-up'),
      targetMuscle: Value('Spalle'),
      equipment: Value('Corpo libero'),
      focusArea: Value('Deltoidi (anteriori, mediali), Tricipiti'),
      preparation: Value(
          'Posizione di \'V\' rovesciata (Down-Dog nello yoga). Mani larghezza spalle, sedere alto.'),
      execution: Value(
          'Piega i gomiti, abbassando la testa verso il pavimento (la testa punta \'avanti\' rispetto alle mani, formando un triangolo). Spingi tornando su, concentrandoti sulle spalle.'),
      tips: Value(
          'Propedeutico per i piegamenti in verticale. Più le mani sono vicine ai piedi, più è difficile.'),
    ),
    ExercisesCompanion(
      name: Value('Handstand Push-up'),
      targetMuscle: Value('Spalle'),
      equipment: Value('Corpo libero, Muro (per supporto)'),
      focusArea: Value('Deltoidi, Tricipiti, Trapezio (avanzato)'),
      preparation: Value(
          'Posizionati in verticale (handstand) con i talloni appoggiati al muro per equilibrio.'),
      execution: Value(
          'Piega lentamente i gomiti, abbassando la testa verso il pavimento (idealmente su un cuscino o pad). Spingi con forza per tornare alla posizione di partenza.'),
      tips: Value(
          'Esercizio molto avanzato. Richiede grande forza nelle spalle e nel core. Inizia con i Pike Push-up o con ROM ridotto.'),
    ),
    ExercisesCompanion(
      name: Value('Cuban Press'),
      targetMuscle: Value('Spalle'),
      equipment: Value('Manubri (molto leggeri)'),
      focusArea: Value('Cuffia dei rotatori, Deltoidi (posteriori, mediali)'),
      preparation: Value(
          'Parti come un\'alzata posteriore (busto a 90° o prono su panca inclinata). Solleva i manubri (gomiti a 90°). Da lì, ruota esternamente le spalle (alzando i manubri).'),
      execution: Value(
          'Il movimento completo (spesso fatto in piedi) è: Tirata al mento (gomiti alti) -> Extrarotazione -> Spinta (Overhead Press). Eseguilo molto lentamente.'),
      tips: Value(
          'Esercizio complesso per la salute e il rinforzo della cuffia dei rotatori. Usa pesi BASSISSIMI (1-3kg).'),
    ),
    ExercisesCompanion(
      name: Value('Scrollate con manubri'),
      targetMuscle: Value('Spalle'),
      equipment: Value('Manubri (pesanti)'),
      focusArea: Value('Trapezio (superiore)'),
      preparation: Value('In piedi, manubri pesanti ai lati del corpo.'),
      execution: Value(
          'Solleva le spalle (\'scrolla\') verticalmente verso le orecchie, senza piegare i gomiti. Contrai il trapezio in cima per 1-2 secondi. Ritorna lentamente.'),
      tips: Value(
          'Non ruotare le spalle (indietro o avanti), è un movimento puramente verticale. Il trapezio risponde bene a carichi pesanti e contrazioni.'),
    ),
    ExercisesCompanion(
      name: Value('Curl con bilanciere'),
      targetMuscle: Value('Bicipiti'),
      equipment: Value('Bilanciere (dritto o EZ)'),
      focusArea: Value('Bicipite brachiale (entrambi i capi), Brachiale'),
      preparation: Value(
          'In piedi, schiena dritta, core contratto. Afferra il bilanciere con presa supina (palmi verso l\'alto) larghezza spalle.'),
      execution: Value(
          'Fletti i gomiti portando il bilanciere verso le spalle. Contrai il bicipite in cima (contrazione di picco). Scendi lentamente in modo controllato fino alla quasi completa estensione.'),
      tips: Value(
          'Evita di dondolare con la schiena (cheating). Mantieni i gomiti fissi ai lati del corpo.'),
    ),
    ExercisesCompanion(
      name: Value('Curl con manubri (In piedi, alternato)'),
      targetMuscle: Value('Bicipiti'),
      equipment: Value('Manubri'),
      focusArea: Value('Bicipite brachiale (enfasi supinazione), Brachiale'),
      preparation: Value(
          'In piedi, manubri ai fianchi con presa neutra (palmi verso il corpo).'),
      execution: Value(
          'Solleva un manubrio flettendo il gomito. Durante la salita, ruota il polso (supinazione) portando il palmo verso l\'alto. Contrai in cima. Scendi controllato tornando in presa neutra. Alterna le braccia.'),
      tips: Value(
          'La supinazione attiva massimizza il lavoro del bicipite. Mantieni il busto fermo.'),
    ),
    ExercisesCompanion(
      name: Value('Curl con manubri (Seduto, simultaneo)'),
      targetMuscle: Value('Bicipiti'),
      equipment: Value('Manubri, Panca'),
      focusArea: Value('Bicipite brachiale'),
      preparation: Value(
          'Seduto su una panca (con o senza schienale). Manubri ai lati con presa supina.'),
      execution: Value(
          'Fletti entrambi i gomiti simultaneamente, portando i manubri verso le spalle. Contrai e ritorna lentamente.'),
      tips: Value(
          'La posizione seduta aiuta a limitare il \'cheating\' con la schiena.'),
    ),
    ExercisesCompanion(
      name: Value('Curl su Panca Scott'),
      targetMuscle: Value('Bicipiti'),
      equipment: Value('Panca Scott (Preacher bench), Bilanciere EZ'),
      focusArea: Value('Bicipite brachiale (focus capo corto, isolamento)'),
      preparation: Value(
          'Siediti alla panca Scott, posiziona la parte posteriore delle braccia (tricipiti) ben aderente al pad. Afferra il bilanciere EZ con presa supina.'),
      execution: Value(
          'Fletti i gomiti portando il bilanciere verso le spalle. Contrai forte in cima. Scendi lentamente finché le braccia non sono quasi tese.'),
      tips: Value(
          'Non estendere completamente in fondo (iperestensione) per proteggere i gomiti. Isolamento puro.'),
    ),
    ExercisesCompanion(
      name: Value('Curl su Panca Scott'),
      targetMuscle: Value('Bicipiti'),
      equipment: Value('Panca Scott, Manubrio'),
      focusArea: Value('Bicipite brachiale (isolamento unilaterale)'),
      preparation: Value(
          'Come la versione con bilanciere, ma usando un solo manubrio. Appoggia il braccio sul pad.'),
      execution: Value(
          'Esegui il curl concentrandoti sulla singola contrazione. Permette di correggere squilibri e massimizzare la supinazione.'),
      tips: Value('Ottimo per la connessione mente-muscolo.'),
    ),
    ExercisesCompanion(
      name: Value('Curl Hammer'),
      targetMuscle: Value('Bicipiti'),
      equipment: Value('Manubri'),
      focusArea: Value('Brachioradiale (avambraccio), Brachiale, Bicipite'),
      preparation: Value(
          'In piedi o seduto. Afferra i manubri con presa neutra (a martello, palmi che si fronteggiano).'),
      execution: Value(
          'Fletti i gomiti portando i manubri verso le spalle, mantenendo sempre la presa neutra. Scendi controllato.'),
      tips: Value(
          'Questo esercizio costruisce spessore nel braccio e rinforza molto gli avambracci.'),
    ),
    ExercisesCompanion(
      name: Value('Curl Hammer'),
      targetMuscle: Value('Bicipiti'),
      equipment: Value('Cavo (Ercolina), Corda'),
      focusArea: Value('Brachioradiale, Brachiale (tensione costante)'),
      preparation: Value(
          'Posiziona la carrucola in basso. Afferra la corda con entrambe le mani (presa neutra).'),
      execution: Value(
          'Esegui un curl a martello tirando la corda verso le spalle. Apri leggermente le mani in cima per aumentare la contrazione. Ritorna lentamente.'),
      tips: Value('Il cavo offre una tensione continua che manca ai manubri.'),
    ),
    ExercisesCompanion(
      name: Value('Curl di concentrazione'),
      targetMuscle: Value('Bicipiti'),
      equipment: Value('Manubrio, Panca'),
      focusArea: Value('Bicipite brachiale (focus contrazione di picco)'),
      preparation: Value(
          'Seduto sul bordo di una panca, gambe divaricate. Appoggia il gomito all\'interno della coscia, braccio teso verso il pavimento.'),
      execution: Value(
          'Fletti il gomito portando il manubrio verso il petto, senza muovere la spalla. Contrai forte (picco) per 1-2 secondi. Scendi lentamente.'),
      tips: Value(
          'Esercizio di isolamento per il \'picco\' del bicipite. Non usare la gamba per spingere.'),
    ),
    ExercisesCompanion(
      name: Value('Curl su panca inclinata'),
      targetMuscle: Value('Bicipiti'),
      equipment: Value('Manubri, Panca inclinata (45-60°)'),
      focusArea: Value('Bicipite brachiale (focus capo lungo, allungamento)'),
      preparation: Value(
          'Sdraiati su una panca inclinata. Lascia cadere le braccia verticalmente verso il pavimento (presa supina o neutra per iniziare).'),
      execution: Value(
          'Fletti i gomiti (alternati o simultanei), portando i manubri alle spalle. Inizia il movimento con il bicipite già in allungamento.'),
      tips: Value(
          'L\'allungamento (stretch) del capo lungo è massimo in questa posizione. Non sollevare le spalle dalla panca.'),
    ),
    ExercisesCompanion(
      name: Value('Zottman Curl'),
      targetMuscle: Value('Bicipiti'),
      equipment: Value('Manubri'),
      focusArea:
          Value('Bicipite (fase concentrica), Avambracci (fase eccentrica)'),
      preparation:
          Value('In piedi o seduto. Parti con presa supina (palmi su).'),
      execution: Value(
          'Esegui un normale curl (fase concentrica). In cima, ruota i polsi in presa prona (palmi giù). Scendi lentamente (fase eccentrica) in presa prona. Ruota di nuovo in supinazione in basso.'),
      tips: Value(
          'Esercizio completo che lavora bicipiti in salita e avambracci (brachioradiale) in discesa.'),
    ),
    ExercisesCompanion(
      name: Value('Curl ai cavi bassi'),
      targetMuscle: Value('Bicipiti'),
      equipment: Value('Cavo (Ercolina), Barra (dritto o EZ)'),
      focusArea: Value('Bicipite brachiale (tensione costante)'),
      preparation: Value(
          'Posiziona la carrucola in basso. Afferra la barra (presa supina). Fai un passo indietro.'),
      execution: Value(
          'Esegui un curl come con il bilanciere. Mantieni i gomiti fissi.'),
      tips: Value(
          'Il cavo fornisce una tensione costante per tutto l\'arco di movimento, a differenza dei pesi liberi.'),
    ),
    ExercisesCompanion(
      name: Value('Curl ai cavi alti'),
      targetMuscle: Value('Bicipiti'),
      equipment: Value('Cavi (Ercolina, stazione doppia), Maniglie'),
      focusArea: Value('Bicipite brachiale (contrazione di picco)'),
      preparation: Value(
          'Posiziona entrambe le carrucole in alto. Mettiti al centro e afferra le maniglie (una per mano). Braccia aperte a \'T\' (posizione \'doppio bicipite\').'),
      execution: Value(
          'Fletti i gomiti portando le maniglie verso le orecchie, contraendo forte i bicipiti. Mantieni le spalle ferme. Ritorna controllato.'),
      tips:
          Value('Esercizio di isolamento estremo per la contrazione di picco.'),
    ),
    ExercisesCompanion(
      name: Value('Reverse Curl con bilanciere'),
      targetMuscle: Value('Bicipiti'),
      equipment: Value('Bilanciere (dritto o EZ)'),
      focusArea:
          Value('Avambracci (Brachioradiale, Estensori polso), Brachiale'),
      preparation: Value(
          'In piedi. Afferra il bilanciere con presa prona (palmi verso il basso) larghezza spalle.'),
      execution: Value(
          'Fletti i gomiti portando il bilanciere in alto. Mantieni i gomiti fissi ai fianchi. Scendi controllato.'),
      tips: Value(
          'Esercizio primario per gli avambracci (parte superiore) e il muscolo brachiale.'),
    ),
    ExercisesCompanion(
      name: Value('Spider Curl'),
      targetMuscle: Value('Bicipiti'),
      equipment: Value('Panca inclinata (30-45°), Manubri (o Bilanciere EZ)'),
      focusArea: Value('Bicipite brachiale (focus capo corto)'),
      preparation: Value(
          'Sdraiati prono (faccia in giù) su una panca inclinata, petto appoggiato. Lascia cadere le braccia verticalmente.'),
      execution: Value(
          'Fletti i gomiti portando i pesi verso le spalle. Le braccia sono perpendicolari al suolo, eliminando qualsiasi slancio (cheating).'),
      tips: Value(
          'Isolamento totale. La posizione impedisce di usare le spalle o la schiena.'),
    ),
    ExercisesCompanion(
      name: Value('Drag Curl con bilanciere'),
      targetMuscle: Value('Bicipiti'),
      equipment: Value('Bilanciere'),
      focusArea: Value('Bicipite brachiale'),
      preparation: Value('In piedi, afferra il bilanciere (presa supina).'),
      execution: Value(
          'Invece di fare un arco, \'trascina\' (drag) il bilanciere lungo il corpo (petto e addome), tirando i gomiti all\'indietro. Contrai in cima.'),
      tips: Value(
          'Movimento diverso che pone enfasi sulla contrazione, mantenendo i gomiti dietro il corpo.'),
    ),
    ExercisesCompanion(
      name: Value('Chin-up'),
      targetMuscle: Value('Bicipiti'),
      equipment: Value('Sbarra per trazioni'),
      focusArea: Value('Dorsali, Bicipite brachiale, Romboidi'),
      preparation: Value(
          'Appeso alla sbarra, presa supina (palmi verso di te) larghezza spalle.'),
      execution: Value(
          'Tira il corpo verso l\'alto finché il mento non supera la sbarra. Concentrati sulla trazione di gomiti e sulla contrazione di dorso e bicipiti. Scendi controllato.'),
      tips: Value(
          'Esercizio composto eccellente. Coinvolge molto i bicipiti (più delle trazioni prone/pull-up).'),
    ),
    ExercisesCompanion(
      name: Value('Preacher Curl (Macchina)'),
      targetMuscle: Value('Bicipiti'),
      equipment: Value('Macchinario (Preacher Curl Machine)'),
      focusArea: Value('Bicipite brachiale (isolamento)'),
      preparation: Value(
          'Siediti alla macchina, regola l\'altezza. Appoggia le braccia sul pad come per la Panca Scott. Afferra le impugnature.'),
      execution: Value(
          'Fletti i gomiti seguendo il movimento guidato dalla macchina. Contrai in cima e ritorna lentamente.'),
      tips: Value(
          'Simile alla Panca Scott ma con un percorso fisso. Ottimo per principianti.'),
    ),
    ExercisesCompanion(
      name: Value('Curl con elastici'),
      targetMuscle: Value('Bicipiti'),
      equipment: Value('Elastici (Resistance bands)'),
      focusArea: Value('Bicipite brachiale (resistenza progressiva)'),
      preparation: Value(
          'In piedi, fissa l\'elastico sotto i piedi. Afferra l\'altra estremità con presa supina.'),
      execution: Value(
          'Esegui un curl. La resistenza aumenta man mano che sali (resistenza progressiva), massimizzando la tensione in cima.'),
      tips: Value('Ottimo per allenarsi a casa o come finisher.'),
    ),
    ExercisesCompanion(
      name: Value('Waiter Curl'),
      targetMuscle: Value('Bicipiti'),
      equipment: Value('Manubrio (singolo)'),
      focusArea: Value('Bicipite (Brachiale, Capo lungo)'),
      preparation: Value(
          'Tieni un solo manubrio in posizione \'a coppa\' (come un cameriere che porta un vassoio), tenendolo piatto sul palmo della mano.'),
      execution: Value(
          'Fletti il gomito portando il manubrio in alto, mantenendolo orizzontale. Contrai e scendi lentamente.'),
      tips: Value(
          'Stimolo unico che richiede molta stabilità del polso e attiva il brachiale.'),
    ),
    ExercisesCompanion(
      name: Value('Dip alle parallele'),
      targetMuscle: Value('Tricipiti'),
      equipment: Value('Parallele (o Dip station)'),
      focusArea:
          Value('Tricipiti (tutti i capi), Deltoidi anteriori, Petto (basso)'),
      preparation: Value(
          'Afferra le parallele, sostieniti a braccia tese. Mantieni il busto il più dritto (verticale) possibile. Gambe incrociate o tese indietro.'),
      execution: Value(
          'Scendi piegando i gomiti (tenendoli vicini al corpo, non larghi) finché il gomito non forma circa 90 gradi. Spingi con forza sui tricipiti per tornare su.'),
      tips: Value(
          'Busto dritto = focus tricipiti. Busto inclinato in avanti = focus petto. Non scendere eccessivamente per proteggere le spalle.'),
    ),
    ExercisesCompanion(
      name: Value('Panca piana presa stretta'),
      targetMuscle: Value('Tricipiti'),
      equipment: Value('Bilanciere, Panca piana, Rack'),
      focusArea: Value(
          'Tricipiti (capo mediale e laterale), Petto (interno), Deltoidi ant.'),
      preparation: Value(
          'Sdraiato su panca piana. Afferra il bilanciere con una presa stretta (larghezza spalle o appena dentro). Stacca dal rack.'),
      execution: Value(
          'Abbassa il bilanciere verso la parte bassa del petto, tenendo i gomiti stretti lungo i fianchi (non larghi). Spingi con forza estendendo i tricipiti.'),
      tips: Value(
          'Non usare una presa troppo stretta (rischio polsi). È un costruttore di massa fondamentale per i tricipiti.'),
    ),
    ExercisesCompanion(
      name: Value('French Press con bilanciere'),
      targetMuscle: Value('Tricipiti'),
      equipment: Value('Bilanciere EZ (o dritto), Panca piana'),
      focusArea: Value('Tricipite (capo lungo e mediale)'),
      preparation: Value(
          'Sdraiato su panca piana. Afferra il bilanciere (presa prona) e portalo sopra il petto a braccia tese.'),
      execution: Value(
          'Mantieni i gomiti fermi (puntati al soffitto). Fletti solo i gomiti, abbassando il bilanciere verso la fronte (\'spacca-cranio\') o appena oltre la testa (per più stretch). Estendi tornando su.'),
      tips: Value(
          'Il bilanciere EZ è più confortevole per i polsi. Non far allargare i gomiti.'),
    ),
    ExercisesCompanion(
      name: Value('French Press con manubri'),
      targetMuscle: Value('Tricipiti'),
      equipment: Value('Manubri, Panca piana'),
      focusArea: Value('Tricipite (tutti i capi, specialmente capo lungo)'),
      preparation: Value(
          'Sdraiato su panca piana. Tieni i manubri sopra il petto. Presa neutra (palmi che si fronteggiano) è la più comune.'),
      execution: Value(
          'Abbassa i manubri ai lati della testa (verso le orecchie/spalle), mantenendo i gomiti fermi. Estendi per tornare su.'),
      tips: Value(
          'I manubri permettono un ROM più naturale e un allungamento maggiore rispetto al bilanciere.'),
    ),
    ExercisesCompanion(
      name: Value('Overhead Extension con manubrio singolo'),
      targetMuscle: Value('Tricipiti'),
      equipment: Value('Manubrio (singolo), Panca (con schienale)'),
      focusArea: Value('Tricipite (focus capo lungo, allungamento)'),
      preparation: Value(
          'Seduto su panca, schiena dritta. Afferra un manubrio con entrambe le mani (presa \'a coppa\' o \'diamante\') e portalo dietro la testa. Gomiti puntati in alto.'),
      execution: Value(
          'Estendi le braccia spingendo il manubrio verso il soffitto. Scendi lentamente tornando in posizione di massimo allungamento.'),
      tips: Value(
          'Massimo stretch per il capo lungo del tricipite. Tieni i gomiti stretti (non larghi).'),
    ),
    ExercisesCompanion(
      name: Value('Overhead Extension con bilanciere'),
      targetMuscle: Value('Tricipiti'),
      equipment: Value('Bilanciere (EZ consigliato), Panca (seduto)'),
      focusArea: Value('Tricipite (focus capo lungo)'),
      preparation:
          Value('Seduto. Afferra il bilanciere EZ e portalo dietro la testa.'),
      execution: Value(
          'Estendi le braccia spingendo il bilanciere verso l\'alto. Scendi controllato.'),
      tips:
          Value('Simile al manubrio singolo ma permette di usare più carico.'),
    ),
    ExercisesCompanion(
      name: Value('Overhead Extension ai cavi'),
      targetMuscle: Value('Tricipiti'),
      equipment: Value('Cavo (Ercolina), Corda'),
      focusArea: Value('Tricipite (capo lungo, tensione costante)'),
      preparation: Value(
          'Posiziona la carrucola in basso. Afferra la corda. Dài le spalle alla macchina e fai un passo avanti. Porta la corda dietro la testa (gomiti flessi).'),
      execution: Value(
          'Estendi le braccia in alto e in avanti (sopra la testa), aprendo la corda in cima. Ritorna controllato in posizione di stretch.'),
      tips: Value(
          'Combina i benefici dello stretch (overhead) con la tensione costante del cavo.'),
    ),
    ExercisesCompanion(
      name: Value('Pushdown ai cavi (Con barra dritta)'),
      targetMuscle: Value('Tricipiti'),
      equipment: Value('Cavo (Ercolina), Barra (dritto o V-bar)'),
      focusArea: Value('Tricipite (focus capo laterale e mediale)'),
      preparation: Value(
          'Posiziona la carrucola in alto. Afferra la barra (presa prona). Gomiti fissi ai fianchi.'),
      execution: Value(
          'Spingi la barra verso il basso fino alla completa estensione delle braccia. Contrai il tricipite. Ritorna lentamente (controlla l\'eccentrica) fino a 90 gradi.'),
      tips: Value(
          'Esercizio di isolamento fondamentale. Non usare il peso del corpo; mantieni il busto fermo e i gomiti bloccati ai fianchi.'),
    ),
    ExercisesCompanion(
      name: Value('Pushdown ai cavi (Con corda)'),
      targetMuscle: Value('Tricipiti'),
      equipment: Value('Cavo (Ercolina), Corda'),
      focusArea: Value('Tricipite (capo laterale, ROM completo)'),
      preparation: Value(
          'Posiziona la carrucola in alto. Afferra la corda (presa neutra). Gomiti ai fianchi.'),
      execution: Value(
          'Spingi la corda verso il basso. Alla fine del movimento, apri (allarga) le mani per massimizzare la contrazione del capo laterale. Ritorna controllato.'),
      tips: Value(
          'La corda permette un ROM leggermente maggiore e una contrazione di picco più intensa.'),
    ),
    ExercisesCompanion(
      name: Value('Pushdown ai cavi (Presa inversa)'),
      targetMuscle: Value('Tricipiti'),
      equipment: Value('Cavo (Ercolina), Maniglia (singola)'),
      focusArea: Value('Tricipite (focus capo mediale)'),
      preparation: Value(
          'Carrucola in alto. Afferra una maniglia singola con presa supina (palmo verso l\'alto). Gomito fisso al fianco.'),
      execution: Value(
          'Spingi verso il basso estendendo il braccio. Concentrati sulla contrazione del capo mediale (vicino al gomito). Ritorna lentamente.'),
      tips: Value(
          'Esercizio di fino, ottimo per isolare il capo mediale, spesso trascurato.'),
    ),
    ExercisesCompanion(
      name: Value('Kickback con manubri'),
      targetMuscle: Value('Tricipiti'),
      equipment: Value('Manubri, Panca (per appoggio)'),
      focusArea: Value('Tricipite (isolamento, contrazione di picco)'),
      preparation: Value(
          'Appoggia un ginocchio e una mano sulla panca (busto parallelo a terra). Nell\'altra mano tieni il manubrio, solleva il gomito fino all\'altezza della schiena e tienilo bloccato lì.'),
      execution: Value(
          'Estendi l\'avambraccio all\'indietro fino a completa estensione. Contrai forte in cima (picco). Ritorna lentamente.'),
      tips: Value(
          'Non far \'cadere\' il gomito. Il movimento è solo dell\'avambraccio. Usa pesi leggeri, è un esercizio di contrazione.'),
    ),
    ExercisesCompanion(
      name: Value('Kickback ai cavi '),
      targetMuscle: Value('Tricipiti'),
      equipment: Value('Cavo (Ercolina), Maniglia (o senza)'),
      focusArea: Value('Tricipite (tensione costante, contrazione picco)'),
      preparation: Value(
          'Posiziona la carrucola in basso. Piegati in avanti (busto 45-90°). Afferra il cavo. Porta il gomito alto e bloccalo.'),
      execution: Value(
          'Estendi il braccio all\'indietro. Il cavo offre tensione costante anche in basso, a differenza del manubrio.'),
      tips: Value('Ottima alternativa ai manubri.'),
    ),
    ExercisesCompanion(
      name: Value('Diamond Push-ups'),
      targetMuscle: Value('Tricipiti'),
      equipment: Value('Corpo libero, Tappetino'),
      focusArea: Value('Tricipiti, Petto (interno), Deltoidi anteriori'),
      preparation: Value(
          'Posizione di plank. Avvicina le mani sotto lo sterno, unendo pollici e indici a formare un \'diamante\'.'),
      execution: Value(
          'Abbassa il corpo controllando il movimento, tenendo i gomiti stretti lungo i fianchi. Spingi con forza sui tricipiti per tornare su.'),
      tips: Value(
          'Molto intenso per i tricipiti. Se troppo difficile, inizia con le ginocchia a terra.'),
    ),
    ExercisesCompanion(
      name: Value('Dip tra panche '),
      targetMuscle: Value('Tricipiti'),
      equipment: Value('Due Panche (o una panca e un rialzo)'),
      focusArea: Value('Tricipiti'),
      preparation: Value(
          'Posiziona le mani (palmi) sul bordo di una panca, dita avanti. Appoggia i talloni sull\'altra panca (o a terra per facilitare).'),
      execution: Value(
          'Abbassa il bacino piegando i gomiti (che puntano indietro) finché non sono a 90°. Spingi sui tricipiti per tornare su.'),
      tips: Value(
          'ATTENZIONE: Non scendere troppo in basso (oltre i 90°) per non stressare eccessivamente l\'articolazione della spalla.'),
    ),
    ExercisesCompanion(
      name: Value('Triceps Extension (Macchina)'),
      targetMuscle: Value('Tricipiti'),
      equipment: Value('Macchinario (Triceps Extension Machine)'),
      focusArea: Value('Tricipiti (isolamento)'),
      preparation: Value(
          'Siediti alla macchina, regola il sedile. Appoggia i gomiti sul pad e afferra le impugnature.'),
      execution: Value(
          'Spingi le leve verso il basso (o in avanti, a seconda della macchina) estendendo completamente i tricipiti. Ritorna controllato.'),
      tips: Value('Movimento guidato e sicuro per isolare i tricipiti.'),
    ),
    ExercisesCompanion(
      name: Value('Tate Press'),
      targetMuscle: Value('Tricipiti'),
      equipment: Value('Manubri, Panca piana'),
      focusArea: Value('Tricipiti, Petto'),
      preparation: Value(
          'Sdraiato su panca piana, manubri sopra il petto (presa prona, come in panca).'),
      execution: Value(
          'Abbassa i manubri verso il centro del petto, facendo \'cadere\' i gomiti larghi (come un\'alzata posteriore al contrario). Spingi tornando su.'),
      tips: Value(
          'Movimento ibrido, non molto comune ma efficace per uno stimolo diverso.'),
    ),
    ExercisesCompanion(
      name: Value('JM Press'),
      targetMuscle: Value('Tricipiti'),
      equipment: Value('Bilanciere (dritto o EZ), Panca piana'),
      focusArea: Value('Tricipiti (massa), Gomiti'),
      preparation: Value(
          'Sdraiato su panca. Presa stretta. È un ibrido tra panca stretta e French Press.'),
      execution: Value(
          'Abbassa il bilanciere in modo controllato verso la gola/petto alto, piegando i gomiti (come un French Press) ma anche muovendo leggermente le spalle (come una Panca Stretta).'),
      tips: Value(
          'Movimento avanzato reso popolare dai powerlifter. Usa cautela.'),
    ),
    ExercisesCompanion(
      name: Value('Floor Press'),
      targetMuscle: Value('Tricipiti'),
      equipment: Value('Bilanciere (o Manubri), Pavimento'),
      focusArea: Value('Tricipiti (lockout), Petto'),
      preparation:
          Value('Sdraiato sul pavimento. Presa stretta sul bilanciere.'),
      execution: Value(
          'Abbassa il bilanciere finché i tricipiti non toccano terra. Fai una pausa (dead-stop) e spingi con forza estendendo i tricipiti.'),
      tips: Value(
          'Il ROM ridotto elimina l\'aiuto delle gambe e si concentra sulla parte finale (lockout) della spinta, dominata dai tricipiti.'),
    ),
    ExercisesCompanion(
      name: Value('Estensioni su panca '),
      targetMuscle: Value('Tricipiti'),
      equipment: Value('Panca, Corpo libero'),
      focusArea: Value('Tricipiti'),
      preparation: Value(
          'Posiziona le mani sul bordo di una panca (presa larghezza spalle). Corpo in posizione plank (piedi a terra indietro).'),
      execution: Value(
          'Piega solo i gomiti, abbassando la testa verso la panca (o sotto il livello della panca). Spingi con i tricipiti per tornare su.'),
      tips: Value(
          'Una sorta di \'Skullcrusher a corpo libero\'. Molto impegnativo.'),
    ),
    ExercisesCompanion(
      name: Value('Piegamenti esplosivi'),
      targetMuscle: Value('Tricipiti'),
      equipment: Value('Corpo libero'),
      focusArea: Value('Tricipiti (potenza, fibre veloci), Petto'),
      preparation: Value('Posizione di push-up (presa media o stretta).'),
      execution: Value(
          'Scendi velocemente e spingi via il pavimento con la massima forza possibile, cercando di staccare le mani da terra (\'clap push-up\' è una variante). Atterra morbidamente e ripeti.'),
      tips: Value(
          'Sviluppa la potenza e la forza esplosiva dei tricipiti e del petto.'),
    ),
    ExercisesCompanion(
      name: Value('Wrist Curls con manubrio'),
      targetMuscle: Value('Avambracci'),
      equipment: Value('Manubrio, Panca (o coscia)'),
      focusArea: Value('Flessori dell\'avambraccio'),
      preparation: Value(
          'Seduto, avambraccio appoggiato sulla coscia o sul bordo di una panca. Polso libero. Impugna il manubrio con presa supina (palmo in su).'),
      execution: Value(
          'Fletti il polso portando il manubrio verso l\'alto il più possibile (contrazione). Scendi lentamente, lasciando che il manubrio allunghi i flessori, quasi \'rotolando\' sulle dita.'),
      tips: Value(
          'Isola il movimento solo al polso. Non muovere l\'avambraccio.'),
    ),
    ExercisesCompanion(
      name: Value('Wrist Curls con bilanciere'),
      targetMuscle: Value('Avambracci'),
      equipment: Value('Bilanciere (dritto o EZ), Panca'),
      focusArea: Value('Flessori dell\'avambraccio'),
      preparation: Value(
          'Seduto, entrambi gli avambracci appoggiati su una panca piana (o sulle cosce), polsi liberi all\'esterno. Presa supina sul bilanciere.'),
      execution: Value(
          'Fletti entrambi i polsi simultaneamente verso l\'alto. Contrai. Scendi lentamente, permettendo al bilanciere di rotolare verso la punta delle dita per un ROM maggiore.'),
      tips: Value(
          'La versione con bilanciere permette carichi maggiori. Controlla la discesa.'),
    ),
    ExercisesCompanion(
      name: Value('Reverse Wrist Curls'),
      targetMuscle: Value('Avambracci'),
      equipment: Value('Manubrio o Bilanciere, Panca'),
      focusArea: Value('Estensori dell\'avambraccio (parte superiore)'),
      preparation: Value(
          'Come i wrist curls, ma con presa prona (palmo in giù). Avambraccio appoggiato sulla coscia o panca, polso libero.'),
      execution: Value(
          'Estendi il polso sollevando il dorso della mano verso l\'alto (verso il soffitto). Contrai gli estensori. Ritorna lentamente.'),
      tips: Value(
          'Richiede un carico significativamente inferiore rispetto ai curl per flessori. Movimento lento e controllato.'),
    ),
    ExercisesCompanion(
      name: Value('Curl Hammer'),
      targetMuscle: Value('Avambracci'),
      equipment: Value('Manubri'),
      focusArea: Value('Brachioradiale (avambraccio), Brachiale, Bicipite'),
      preparation: Value(
          'In piedi o seduto. Afferra i manubri con presa neutra (a martello, palmi che si fronteggiano).'),
      execution: Value(
          'Fletti i gomiti portando i manubri verso le spalle, mantenendo sempre la presa neutra. Scendi controllato.'),
      tips: Value(
          'Esercizio fondamentale per costruire spessore nell\'avambraccio (brachioradiale).'),
    ),
    ExercisesCompanion(
      name: Value('Reverse Barbell Curl'),
      targetMuscle: Value('Avambracci'),
      equipment: Value('Bilanciere (dritto o EZ)'),
      focusArea: Value('Brachioradiale, Estensori del polso, Brachiale'),
      preparation: Value(
          'In piedi. Afferra il bilanciere con presa prona (palmi verso il basso) larghezza spalle.'),
      execution: Value(
          'Fletti i gomiti portando il bilanciere in alto, mantenendo i gomiti fissi ai fianchi. Scendi controllato.'),
      tips: Value(
          'Esercizio primario per la parte superiore degli avambracci e per la forza dei polsi in estensione.'),
    ),
    ExercisesCompanion(
      name: Value('Farmer\'s Walk'),
      targetMuscle: Value('Avambracci'),
      equipment:
          Value('Manubri (pesanti), Kettlebell, o Farmer\'s Walk handles'),
      focusArea: Value(
          'Forza della presa (Grip strength), Trapezi, Core, Stabilizzatori'),
      preparation: Value(
          'Stacca da terra due manubri/kettlebell pesanti (come uno stacco). Stai in piedi dritto, petto in fuori, core contratto, spalle depresse.'),
      execution: Value(
          'Cammina a passi controllati ma decisi per una distanza o un tempo prestabiliti. Mantieni la postura eretta, non inclinarti e non dondolare.'),
      tips: Value(
          'Uno dei migliori esercizi totali per la forza della presa (resistenza isometrica).'),
    ),
    ExercisesCompanion(
      name: Value('Hand Grippers'),
      targetMuscle: Value('Avambracci'),
      equipment: Value('Hand Grippers (pinze a molla)'),
      focusArea: Value('Forza della presa (schiacciamento, crushing grip)'),
      preparation: Value(
          'Impugna la pinza con una mano. Posizionala correttamente nel palmo.'),
      execution: Value(
          'Chiudi la pinza (schiaccia) fino a far toccare le due impugnature (se possibile). Mantieni la contrazione per 1-2 secondi. Rilascia lentamente (controllo eccentrico).'),
      tips: Value(
          'Ottimo per aumentare la forza di schiacciamento. Lavora su basse rep (forza) o alte rep (resistenza).'),
    ),
    ExercisesCompanion(
      name: Value('Plate Pinch'),
      targetMuscle: Value('Avambracci'),
      equipment: Value('Dischi (preferibilmente lisci)'),
      focusArea: Value('Forza della presa (dita, pinza, pinch grip)'),
      preparation: Value(
          'Posiziona due dischi della stessa dimensione uno contro l\'altro, con il lato liscio rivolto verso l\'esterno.'),
      execution: Value(
          'Afferra i dischi solo con le dita e il pollice (presa \'a pinza\'). Sollevali da terra e tienili il più a lungo possibile (isometria) o cammina.'),
      tips: Value(
          'Esercizio brutale per la forza delle dita e del pollice. Inizia con dischi leggeri (es. 2x5kg o 2x10kg).'),
    ),
    ExercisesCompanion(
      name: Value('Sospensioni alla sbarra (Dead Hang)'),
      targetMuscle: Value('Avambracci'),
      equipment: Value('Sbarra per trazioni'),
      focusArea: Value('Resistenza della presa, Decompressione spinale'),
      preparation:
          Value('Afferra la sbarra (presa prona o supina) larghezza spalle.'),
      execution: Value(
          'Rimani appeso alla sbarra (piedi sollevati da terra) per il tempo massimo possibile (time under tension).'),
      tips: Value(
          'Esercizio isometrico fondamentale per la resistenza della presa. Prova anche la sospensione a un braccio o con asciugamani per aumentare la difficoltà.'),
    ),
    ExercisesCompanion(
      name: Value('Avvolgimento del polso (Wrist Roller)'),
      targetMuscle: Value('Avambracci'),
      equipment: Value('Wrist roller (rullo per polsi) e peso'),
      focusArea: Value('Flessori ed Estensori (resistenza, ipertrofia)'),
      preparation: Value(
          'Tieni il wrist roller davanti a te a braccia tese (più difficile) o piegate. Il peso è appeso alla corda, vicino a terra.'),
      execution: Value(
          'Avvolgi la corda attorno al rullo ruotando i polsi (sia in estensione che in flessione) fino a che il peso non arriva in cima. Svolgi lentamente (controllo eccentrico).'),
      tips: Value(
          'Brucia incredibilmente gli avambracci. Assicurati di allenare sia il movimento di \'avvolgimento\' (estensione) che quello di \'svolgimento\' (flessione).'),
    ),
    ExercisesCompanion(
      name: Value('Back Squat'),
      targetMuscle: Value('Gambe'),
      equipment: Value('Bilanciere, Rack (Squat rack), Pesi'),
      focusArea: Value('Quadricipiti, Glutei, Ischiocrurali, Core'),
      preparation: Value(
          'Posiziona il bilanciere sul rack all\'altezza delle spalle. Mettiti sotto, appoggialo sui trapezi (high bar) o deltoidi posteriori (low bar). Stacca il bilanciere, fai 1-2 passi indietro. Piedi larghezza spalle, punte leggermente extraruotate.'),
      execution: Value(
          'Inspira e contrai il core. Scendi controllando il movimento (sedere indietro e in basso), idealmente rompendo il parallelo (anca sotto il ginocchio). Mantieni la schiena neutra. Spingi con forza sui talloni/mesopiede per tornare su, espirando.'),
      tips: Value(
          'Mantieni il petto \'alto\' e lo sguardo in avanti o leggermente in basso. Non far collassare le ginocchia verso l\'interno (spingile attivamente fuori).'),
    ),
    ExercisesCompanion(
      name: Value('Front Squat'),
      targetMuscle: Value('Gambe'),
      equipment: Value('Bilanciere, Rack, Pesi'),
      focusArea:
          Value('Quadricipiti (focus primario), Glutei, Core (molto intenso)'),
      preparation: Value(
          'Posiziona il bilanciere sul rack. Avvicinati e posizionalo sui deltoidi anteriori. Incrocia le braccia (presa \'bodybuilder\') o usa la presa \'clean\' (polsi estesi, gomiti alti). Stacca, fai 1-2 passi indietro.'),
      execution: Value(
          'Scendi mantenendo il busto il più verticale possibile e i gomiti alti. Scendi in accosciata profonda (deep squat). Spingi per tornare su, mantenendo sempre i gomiti sollevati.'),
      tips: Value(
          'Il busto eretto è fondamentale. Se i gomiti cadono, il bilanciere scivolerà. Grande lavoro per il core e la mobilità toracica.'),
    ),
    ExercisesCompanion(
      name: Value('Stacco da terra (Deadlift)'),
      targetMuscle: Value('Gambe'),
      equipment: Value('Bilanciere, Pesi'),
      focusArea: Value(
          'Ischiocrurali, Glutei, Schiena (Erettori spinali, Dorsali), Core'),
      preparation: Value(
          'Piedi larghezza fianchi sotto il bilanciere (deve tagliare il piede a metà). Piegati e afferra il bilanciere (presa prona o mista) appena fuori dalle ginocchia. Abbassa il bacino, schiena piatta e tesa, petto in fuori.'),
      execution: Value(
          'Spingi con le gambe \'allontanando il pavimento\'. Quando il bilanciere supera le ginocchia, estendi l\'anca portando il bacino in avanti. Chiudi il movimento in piedi, dritto. Scendi in modo controllato.'),
      tips: Value(
          'La schiena DEVE rimanere neutra, mai curvarsi (\'gatto\'). Pensa a \'spingere\' con le gambe, non a \'tirare\' con la schiena.'),
    ),
    ExercisesCompanion(
      name: Value('Stacco da terra (Sumo)'),
      targetMuscle: Value('Gambe'),
      equipment: Value('Bilanciere, Pesi'),
      focusArea: Value('Glutei, Ischiocrurali, Quadricipiti, Adduttori'),
      preparation: Value(
          'Piedi molto larghi, punte rivolte verso l\'esterno (varia in base alla mobilità). Afferra il bilanciere all\'interno delle gambe (presa larghezza spalle). Scendi in posizione con il busto più eretto rispetto al convenzionale.'),
      execution: Value(
          'Spingi con le gambe, allargando attivamente le ginocchia verso l\'esterno (in linea con le punte dei piedi). Estendi l\'anca per chiudere il movimento. Contrai i glutei in cima.'),
      tips: Value(
          'Richiede molta mobilità dell\'anca. Permette al busto di stare più verticale, riducendo lo stress lombare per alcuni.'),
    ),
    ExercisesCompanion(
      name: Value('Stacco Romeno'),
      targetMuscle: Value('Gambe'),
      equipment: Value('Bilanciere o Manubri'),
      focusArea: Value('Ischiocrurali (focus primario), Glutei'),
      preparation: Value(
          'Parti in piedi con il bilanciere/manubri in mano (puoi staccarlo da un rack). Gambe leggermente piegate (ma fisse), piedi larghezza fianchi.'),
      execution: Value(
          'Spingi il bacino indietro (\'chiudi un cassetto col sedere\'), mantenendo la schiena piatta e il bilanciere/manubri vicino alle gambe. Scendi finché senti un forte allungamento negli ischiocrurali (solitamente sotto il ginocchio). Torna su estendendo l\'anca.'),
      tips: Value(
          'Non è uno stacco da terra. Il movimento è un\'estensione d\'anca (hip hinge), le ginocchia restano quasi bloccate. Il focus è l\'allungamento (stretch).'),
    ),
    ExercisesCompanion(
      name: Value('Leg Press (Pressa a 45°)'),
      targetMuscle: Value('Gambe'),
      equipment: Value('Macchinario (Leg Press)'),
      focusArea: Value(
          'Quadricipiti, Glutei, Ischiocrurali (varia con posizione piedi)'),
      preparation: Value(
          'Siediti sulla pressa, schiena e glutei ben aderenti al sedile. Posiziona i piedi sulla piattaforma (larghezza spalle, medi).'),
      execution: Value(
          'Sblocca la sicura. Scendi in modo controllato piegando le ginocchia finché non raggiungono circa 90 gradi (o finché il bacino non inizia a staccarsi). Spingi con forza per tornare su, senza bloccare le ginocchia in cima.'),
      tips: Value(
          'Piedi alti = focus glutei/ischi. Piedi bassi = focus quadricipiti. Non staccare MAI il bacino dallo schienale in fondo al movimento (retroversione).'),
    ),
    ExercisesCompanion(
      name: Value('Affondi con manubri'),
      targetMuscle: Value('Gambe'),
      equipment: Value('Manubri'),
      focusArea: Value('Quadricipiti, Glutei (lavoro unilaterale)'),
      preparation:
          Value('In piedi, schiena dritta, manubri ai lati del corpo.'),
      execution: Value(
          'Fai un passo lungo in avanti. Abbassa il corpo finché entrambe le ginocchia non formano circa 90 gradi. Il ginocchio posteriore quasi sfiora terra. Spingi sul tallone della gamba anteriore per tornare alla posizione di partenza. Alterna gamba.'),
      tips: Value(
          'Mantieni il busto eretto. Il passo non deve essere né troppo corto (stress sul ginocchio ant.) né troppo lungo (instabilità).'),
    ),
    ExercisesCompanion(
      name: Value('Affondi con bilanciere'),
      targetMuscle: Value('Gambe'),
      equipment: Value('Bilanciere, Rack'),
      focusArea:
          Value('Quadricipiti, Glutei, Core (maggiore richiesta di stabilità)'),
      preparation: Value(
          'Posiziona il bilanciere sulla schiena come in uno squat (high bar). Stacca dal rack.'),
      execution: Value(
          'Come gli affondi con manubri, ma richiede più equilibrio. Fai un passo avanti, scendi controllato (ginocchia a 90°), spingi per tornare su. Spesso eseguiti camminando (walking lunges).'),
      tips: Value(
          'Richiede molta più stabilità e forza del core rispetto ai manubri. Usa un peso inferiore all\'inizio.'),
    ),
    ExercisesCompanion(
      name: Value('Affondi Bulgari'),
      targetMuscle: Value('Gambe'),
      equipment: Value('Manubri (o Bilanciere), Panca (o rialzo)'),
      focusArea: Value('Glutei (focus primario), Quadricipiti'),
      preparation: Value(
          'Posiziona il collo del piede posteriore su una panca. Fai un passo avanti con l\'altra gamba. Tieni i manubri ai lati.'),
      execution: Value(
          'Scendi verticalmente finché il ginocchio posteriore non è vicino al pavimento. Il busto può inclinarsi leggermente in avanti per aumentare il focus sui glutei. Spingi sul tallone della gamba anteriore per tornare su.'),
      tips: Value(
          'Esercizio eccellente per i glutei. La distanza dalla panca determina il focus: più lontano = più glutei; più vicino = più quadricipiti.'),
    ),
    ExercisesCompanion(
      name: Value('Leg Extension'),
      targetMuscle: Value('Gambe'),
      equipment: Value('Macchinario (Leg Extension)'),
      focusArea: Value('Quadricipiti (isolamento puro)'),
      preparation: Value(
          'Siediti sulla macchina, regola lo schienale in modo che le ginocchia siano allineate con il perno di rotazione. Posiziona il cuscinetto sulle caviglie.'),
      execution: Value(
          'Estendi completamente le gambe contraendo i quadricipiti. Mantieni la contrazione (picco) per 1 secondo. Ritorna lentamente e in modo controllato alla posizione di partenza.'),
      tips: Value(
          'Puro isolamento. Non usare slancio o pesi eccessivi che stressano l\'articolazione del ginocchio. Controlla la fase eccentrica (discesa).'),
    ),
    ExercisesCompanion(
      name: Value('Leg Curl (sdraiato)'),
      targetMuscle: Value('Gambe'),
      equipment: Value('Macchinario (Lying Leg Curl)'),
      focusArea: Value('Ischiocrurali (isolamento)'),
      preparation: Value(
          'Sdraiati prono sulla macchina. Posiziona il cuscinetto sopra i talloni (tendine d\'Achille). Afferra le maniglie e tieni il bacino premuto contro la panca.'),
      execution: Value(
          'Fletti le ginocchia portando i talloni verso i glutei. Contrai gli ischiocrurali. Ritorna lentamente alla posizione iniziale, controllando l\'eccentrica.'),
      tips: Value(
          'Non sollevare il bacino dalla panca durante il movimento; ciò toglie lavoro agli ischiocrurali e lo sposta sulla schiena.'),
    ),
    ExercisesCompanion(
      name: Value('Leg Curl (seduto)'),
      targetMuscle: Value('Gambe'),
      equipment: Value('Macchinario (Seated Leg Curl)'),
      focusArea: Value('Ischiocrurali (isolamento, focus sull\'allungamento)'),
      preparation: Value(
          'Siediti sulla macchina, regola il cuscinetto superiore per bloccare le cosce. Posiziona il cuscinetto inferiore dietro le caviglie.'),
      execution: Value(
          'Fletti le ginocchia portando i talloni sotto il sedile. Contrai e ritorna lentamente. Il movimento è molto controllato.'),
      tips: Value(
          'La versione seduta lavora gli ischiocrurali in una posizione di maggiore allungamento (anca flessa) rispetto alla versione sdraiata, ottimo per l\'ipertrofia.'),
    ),
    ExercisesCompanion(
      name: Value('Goblet Squat'),
      targetMuscle: Value('Gambe'),
      equipment: Value('Manubrio (o Kettlebell)'),
      focusArea: Value('Quadricipiti, Glutei, Core'),
      preparation: Value(
          'Tieni un manubrio verticalmente (o un kettlebell) davanti al petto con entrambe le mani. Piedi larghezza spalle.'),
      execution: Value(
          'Scendi in uno squat profondo, mantenendo il busto molto eretto (il peso funge da contrappeso). I gomiti possono scendere all\'interno delle ginocchia. Spingi per tornare su.'),
      tips: Value(
          'Eccellente per imparare lo schema motorio dello squat e per rinforzare il core. Mantieni il petto \'alto\'.'),
    ),
    ExercisesCompanion(
      name: Value('Hip Thrust (Bilanciere)'),
      targetMuscle: Value('Gambe'),
      equipment: Value('Panca piana, Bilanciere, Pesi, (Pad per bilanciere)'),
      focusArea: Value('Glutei (focus primario), Ischiocrurali'),
      preparation: Value(
          'Siediti a terra con la parte alta della schiena (sotto le scapole) appoggiata al lato di una panca. Posiziona il bilanciere sopra il bacino (usa un pad!). Piedi a terra, ginocchia piegate.'),
      execution: Value(
          'Spingi con forza i talloni a terra, sollevando il bacino fino a formare un \'ponte\' (corpo parallelo al suolo dalle spalle alle ginocchia). Contrai i glutei al massimo in cima. Scendi controllato.'),
      tips: Value(
          'Lo sguardo deve essere in avanti (mento verso lo sterno), non verso il soffitto, per mantenere la colonna vertebrale allineata. È l\'esercizio principale per i glutei.'),
    ),
    ExercisesCompanion(
      name: Value('Good Morning (Bilanciere)'),
      targetMuscle: Value('Gambe'),
      equipment: Value('Bilanciere, Rack'),
      focusArea: Value('Ischiocrurali, Glutei, Erettori spinali'),
      preparation: Value(
          'Posiziona il bilanciere sulla schiena (come uno squat \'low bar\'). Piedi larghezza fianchi, ginocchia leggermente flesse (ma fisse).'),
      execution: Value(
          'Esegui un \'inchino\' spingendo il bacino indietro e flettendo il busto in avanti. Mantieni la schiena piatta e tesa. Scendi finché il busto non è quasi parallelo al suolo. Torna su estendendo l\'anca.'),
      tips: Value(
          'Molto simile a un RDL ma col carico sulla schiena. Usa pesi LEGGERI. È un movimento di \'hip hinge\', non una flessione della schiena.'),
    ),
    ExercisesCompanion(
      name: Value('Hack Squat (Macchinario)'),
      targetMuscle: Value('Gambe'),
      equipment: Value('Macchinario (Hack Squat)'),
      focusArea: Value('Quadricipiti (focus intenso)'),
      preparation: Value(
          'Posizionati sulla macchina con le spalle sotto i supporti e la schiena ben appoggiata allo schienale. Piedi sulla piattaforma (posizione medio-bassa per focus sui quad).'),
      execution: Value(
          'Sblocca le sicure. Scendi in accosciata profonda, mantenendo la schiena aderente. Spingi per tornare su, senza bloccare le ginocchia.'),
      tips: Value(
          'Permette un\'accosciata profonda con supporto per la schiena, ottimo per isolare i quadricipiti. Variare la posizione dei piedi cambia il focus.'),
    ),
    ExercisesCompanion(
      name: Value('Sissy Squat'),
      targetMuscle: Value('Gambe'),
      equipment: Value('Corpo libero (con supporto) o Macchina specifica'),
      focusArea: Value('Quadricipiti (isolamento, focus retto femorale)'),
      preparation: Value(
          'In piedi, afferra un supporto per l\'equilibrio (se a corpo libero). Piedi vicini.'),
      execution: Value(
          'Piegati all\'indietro solo sulle ginocchia, sollevando i talloni. Il corpo forma una linea dritta dalle ginocchia alla testa, inclinata all\'indietro. Scendi finché le ginocchia quasi toccano terra. Torna su estendendo i quadricipiti.'),
      tips: Value(
          'Esercizio avanzato di isolamento. Mette molta tensione sul retto femorale. Procedi con cautela per non stressare le ginocchia.'),
    ),
    ExercisesCompanion(
      name: Value('Step-Up (Manubri)'),
      targetMuscle: Value('Gambe'),
      equipment: Value('Panca (o Box pliometrico), Manubri'),
      focusArea: Value('Quadricipiti, Glutei (lavoro unilaterale)'),
      preparation: Value(
          'In piedi di fronte a una panca o box, tieni i manubri ai lati. Appoggia un piede completamente sulla panca.'),
      execution: Value(
          'Spingi sul tallone del piede sul box per sollevare tutto il corpo, portando l\'altro ginocchio in alto. Scendi in modo controllato, usando solo la gamba che lavora (non spingere con la gamba a terra).'),
      tips: Value(
          'Non \'rimbalzare\' o spingere con la gamba a terra. Il lavoro deve essere tutto a carico della gamba sul rialzo. Ottimo per l\'equilibrio.'),
    ),
    ExercisesCompanion(
      name: Value('Stacco a gambe tese'),
      targetMuscle: Value('Gambe'),
      equipment: Value('Bilanciere (o Manubri)'),
      focusArea: Value('Ischiocrurali (focus sull\'allungamento), Glutei'),
      preparation: Value(
          'Simile al RDL, ma le ginocchia sono quasi completamente bloccate (solo una micro-flessione per sicurezza). Schiena piatta.'),
      execution: Value(
          'Fletti il busto in avanti mantenendo le gambe tese. Scendi finché puoi mantenendo la schiena piatta. Il bilanciere potrebbe allontanarsi di più dalle gambe rispetto a un RDL. Torna su contraendo glutei e ischio.'),
      tips: Value(
          'Spesso confuso con l\'RDL. L\'RDL è un \'hip hinge\' (sedere indietro), lo stacco a gambe tese è più simile a un \'inchino\' con focus sull\'allungamento massimo.'),
    ),
    ExercisesCompanion(
      name: Value('Glute Ham Raise'),
      targetMuscle: Value('Gambe'),
      equipment: Value('Macchinario GHR (o panca apposita)'),
      focusArea:
          Value('Ischiocrurali (entrambe le funzioni), Glutei, Polpacci'),
      preparation: Value(
          'Posizionati sulla macchina GHR, caviglie bloccate, ginocchia appoggiate sul cuscinetto, busto eretto.'),
      execution: Value(
          'Lasciati \'cadere\' in avanti in modo controllato (eccentrica), mantenendo il corpo dritto (dalle ginocchia alla testa). Torna su flettendo prima le ginocchia (come un leg curl) e poi estendendo l\'anca.'),
      tips: Value(
          'Esercizio durissimo e completo per la catena posteriore. Molti iniziano usando un elastico di supporto o solo la fase eccentrica.'),
    ),
    ExercisesCompanion(
      name: Value('Calf Raises in piedi (Alla macchina)'),
      targetMuscle: Value('Polpacci'),
      equipment: Value('Macchina (Standing Calf Raise)'),
      focusArea: Value('Gastrocnemio (gemelli)'),
      preparation: Value(
          'Posizionarsi sulla macchina dedicata. Spalle sotto i cuscinetti imbottiti, avampiedi sulla piattaforma, talloni liberi di scendere.'),
      execution: Value(
          'Spingere sui talloni sollevandosi il più in alto possibile sulle punte dei piedi. Mantenere la contrazione di picco per 1-2 secondi. Scendere lentamente sotto il livello della piattaforma per massimizzare l\'allungamento (stretch).'),
      tips: Value(
          'Mantenere le ginocchia quasi completamente tese (ma non bloccate) per focalizzare il lavoro sul gastrocnemio. Non \'rimbalzare\' in basso.'),
    ),
    ExercisesCompanion(
      name: Value('Calf Raises in piedi (Con bilanciere)'),
      targetMuscle: Value('Polpacci'),
      equipment: Value('Bilanciere, Rialzo (step o disco robusto)'),
      focusArea: Value('Gastrocnemio, Stabilizzatori (Core, Caviglie)'),
      preparation: Value(
          'Posizionare un bilanciere sulla schiena (come nello squat). Posizionare gli avampiedi su un rialzo stabile, talloni liberi.'),
      execution: Value(
          'Mantenendo l\'equilibrio e il core contratto, sollevarsi sulle punte dei piedi. Contrazione di picco. Scendere lentamente in allungamento.'),
      tips: Value(
          'Richiede molto equilibrio. È consigliabile eseguirlo dentro un rack per sicurezza. Iniziare con carichi bassi per padroneggiare il movimento.'),
    ),
    ExercisesCompanion(
      name: Value('Calf Raises in piedi (Smith Machine)'),
      targetMuscle: Value('Polpacci'),
      equipment: Value('Smith Machine (Multipower), Rialzo'),
      focusArea: Value('Gastrocnemio'),
      preparation: Value(
          'Posizionare la sbarra del Multipower sulla schiena. Posizionare un rialzo sotto i piedi e salirci con gli avampiedi.'),
      execution: Value(
          'Eseguire il calf raise sollevandosi sulle punte. Contrazione. Scendere lentamente in stretch.'),
      tips: Value(
          'Molto più stabile del bilanciere libero, permette di concentrarsi esclusivamente sulla contrazione dei polpacci senza preoccuparsi dell\'equilibrio.'),
    ),
    ExercisesCompanion(
      name: Value('Calf Raises in piedi (Manubrio)'),
      targetMuscle: Value('Polpacci'),
      equipment: Value('Manubrio, Rialzo, Supporto (per equilibrio)'),
      focusArea: Value('Gastrocnemio (lavoro unilaterale)'),
      preparation: Value(
          'Tenere un manubrio in una mano (es. destra). Appoggiare l\'avampiede della stessa gamba (destra) su un rialzo. Tenersi con l\'altra mano (sinistra) a un supporto per l\'equilibrio. L\'altra gamba (sinistra) è piegata e sollevata.'),
      execution: Value(
          'Sollevare il tallone (destro) il più in alto possibile, contraendo il polpaccio. Scendere lentamente in massimo allungamento.'),
      tips: Value(
          'Il lavoro unilaterale è eccellente per correggere squilibri muscolari e permette un ROM (arco di movimento) completo.'),
    ),
    ExercisesCompanion(
      name: Value('Calf Raises seduto (Macchina)'),
      targetMuscle: Value('Polpacci'),
      equipment: Value('Macchina (Seated Calf Raise)'),
      focusArea: Value('Soleo'),
      preparation: Value(
          'Sedersi alla macchina specifica. Posizionare le ginocchia sotto i cuscinetti imbottiti. Avampiedi sulla piattaforma, talloni liberi.'),
      execution: Value(
          'Spingere con le punte sollevando i talloni, contraendo il polpaccio. Mantenere la contrazione. Scendere lentamente in allungamento.'),
      tips: Value(
          'Tenere le ginocchia piegate a 90° esclude gran parte del gastrocnemio (che è bi-articolare) e isola il lavoro sul soleo, un muscolo importante per lo \'spessore\' del polpaccio.'),
    ),
    ExercisesCompanion(
      name: Value('Calf Raises alla Pressa 45°'),
      targetMuscle: Value('Polpacci'),
      equipment: Value('Leg Press (Pressa a 45°)'),
      focusArea: Value('Gastrocnemio, Soleo'),
      preparation: Value(
          'Sedersi alla pressa. Posizionare solo gli avampiedi sulla parte bassa della piattaforma, talloni liberi. Spingere per stendere le gambe (NON bloccare le ginocchia!).'),
      execution: Value(
          'Mantenendo le gambe quasi tese, spingere la piattaforma con le punte (flessione plantare). Contrazione. Rilasciare lentamente (flessione dorsale) per l\'allungamento.'),
      tips: Value(
          'ATTENZIONE: Non bloccare mai le ginocchia (rischio infortunio). Questo esercizio permette di usare carichi molto elevati in sicurezza.'),
    ),
    ExercisesCompanion(
      name: Value('Calf Raises su scalino, 2 gambe)'),
      targetMuscle: Value('Polpacci'),
      equipment: Value('Scalino (o rialzo), Corpo libero'),
      focusArea: Value('Gastrocnemio, Soleo'),
      preparation: Value(
          'In piedi, posizionare gli avampiedi sul bordo di uno scalino, talloni liberi nel vuoto.'),
      execution: Value(
          'Sollevarsi su entrambe le punte il più in alto possibile. Mantenere la contrazione. Scendere lentamente portando i talloni sotto il livello dello scalino per un allungamento completo.'),
      tips: Value(
          'Ottimo per alte ripetizioni (burnout) o come riscaldamento. Tenersi a un corrimano o al muro per l\'equilibrio.'),
    ),
    ExercisesCompanion(
      name: Value('Calf Raises su scalino, 1 gamba)'),
      targetMuscle: Value('Polpacci'),
      equipment: Value('Scalino (o rialzo), Corpo libero'),
      focusArea: Value('Gastrocnemio, Soleo (unilaterale)'),
      preparation: Value(
          'Come il precedente, ma tutto il peso è su una gamba sola. L\'altra gamba è sollevata o piegata all\'indietro.'),
      execution: Value(
          'Sollevarsi sulla punta della gamba che lavora. Contrazione. Scendere lentamente in massimo allungamento.'),
      tips: Value(
          'Molto più intenso e sfidante rispetto alla versione a due gambe. Ottimo per sviluppare forza unilaterale senza bisogno di pesi.'),
    ),
    ExercisesCompanion(
      name: Value('Salti su box pliometrici'),
      targetMuscle: Value('Polpacci'),
      equipment: Value('Box pliometrico (Plywood box)'),
      focusArea: Value('Polpacci (potenza esplosiva), Quadricipiti, Glutei'),
      preparation: Value(
          'In piedi di fronte a un box di altezza adeguata (iniziare bassi). Posizione di partenza in leggero semi-squat.'),
      execution: Value(
          'Eseguire un salto esplosivo per atterrare morbidamente (in semi-squat) sopra il box. La spinta parte dalla tripla estensione: caviglia (polpacci), ginocchio (quadricipiti) e anca (glutei).'),
      tips: Value(
          'Esercizio pliometrico per la potenza, non per l\'ipertrofia pura. I polpacci lavorano in modo esplosivo. Scendere dal box camminando (step down), non saltare all\'indietro.'),
    ),
    ExercisesCompanion(
      name: Value('Crunch'),
      targetMuscle: Value('Addominali'),
      equipment: Value('Corpo libero, Tappetino'),
      focusArea: Value('Retto dell\'addome (focus parte alta)'),
      preparation: Value(
          'Sdraiato supino, ginocchia piegate, piedi a terra. Mani al petto o ai lati della testa (non tirare il collo!).'),
      execution: Value(
          'Solleva spalle e parte alta della schiena da terra, contraendo l\'addome. Pensa ad \'accorciare\' lo spazio tra sterno e bacino. La zona lombare rimane a terra. Scendi controllato.'),
      tips: Value(
          'Non tirare la testa con le mani. Il movimento è breve e concentrato. Espira quando sali.'),
    ),
    ExercisesCompanion(
      name: Value('Crunch inverso'),
      targetMuscle: Value('Addominali'),
      equipment: Value('Corpo libero, Tappetino'),
      focusArea: Value('Retto dell\'addome (focus parte bassa)'),
      preparation: Value(
          'Sdraiato supino, braccia lungo i fianchi (palmi a terra per stabilità). Solleva le gambe con ginocchia piegate a 90°.'),
      execution: Value(
          'Contrai l\'addome per sollevare il bacino da terra, portando le ginocchia verso il petto. Il movimento è controllato (non uno slancio). Ritorna lentamente.'),
      tips: Value(
          'Focalizzati sul sollevare il bacino (retroversione), non solo sullo slanciare le gambe.'),
    ),
    ExercisesCompanion(
      name: Value('Plank'),
      targetMuscle: Value('Addominali'),
      equipment: Value('Corpo libero, Tappetino'),
      focusArea: Value('Core (Trasverso, Retto), Stabilità totale'),
      preparation: Value(
          'Posizionati sugli avambracci (paralleli o mani giunte) e sulle punte dei piedi. Corpo dritto come una tavola (testa, spalle, bacino, talloni allineati).'),
      execution: Value(
          'Mantieni la posizione contraendo addome e glutei. Non far cadere il bacino (iperlordosi) e non alzarlo troppo.'),
      tips: Value(
          'Respira regolarmente. Contrai attivamente glutei e addome (\'tira l\'ombelico verso la colonna\') per massima efficacia.'),
    ),
    ExercisesCompanion(
      name: Value('Side Plank'),
      targetMuscle: Value('Addominali'),
      equipment: Value('Corpo libero, Tappetino'),
      focusArea: Value('Obliqui, Quadrato dei lombi, Gluteo medio'),
      preparation: Value(
          'Appoggiati su un avambraccio (gomito sotto la spalla) e sul lato del piede. Corpo dritto lateralmente.'),
      execution: Value(
          'Solleva il fianco da terra e mantieni la linea retta. Non lasciare che il fianco \'cada\' verso il pavimento.'),
      tips: Value(
          'Per facilitare, appoggia il ginocchio inferiore. Per intensificare, solleva la gamba superiore.'),
    ),
    ExercisesCompanion(
      name: Value('Sollevamento gambe'),
      targetMuscle: Value('Addominali'),
      equipment: Value('Sbarra per trazioni (o apposita \'Captain\'s Chair\')'),
      focusArea: Value('Retto dell\'addome (parte bassa), Flessori dell\'anca'),
      preparation: Value('Appeso alla sbarra (presa salda). Corpo fermo.'),
      execution: Value(
          'Solleva le gambe tese (o quasi tese) fino a formare 90 gradi (parallele al suolo) o più in alto. Scendi in modo controllato senza dondolare.'),
      tips: Value(
          'Evita di dondolare (usa il core per stabilizzare). Se troppo difficile, inizia con le ginocchia (Knee Raises).'),
    ),
    ExercisesCompanion(
      name: Value('Sollevamento ginocchia'),
      targetMuscle: Value('Addominali'),
      equipment: Value('Sbarra per trazioni (o \'Captain\'s Chair\')'),
      focusArea: Value('Retto dell\'addome (parte bassa), Flessori dell\'anca'),
      preparation: Value('Appeso alla sbarra.'),
      execution: Value(
          'Solleva le ginocchia verso il petto, contraendo l\'addome e sollevando leggermente il bacino in cima (retroversione). Scendi controllato.'),
      tips:
          Value('Versione più facile del \'Leg Raises\', ottima per iniziare.'),
    ),
    ExercisesCompanion(
      name: Value('Sollevamento gambe a terra'),
      targetMuscle: Value('Addominali'),
      equipment: Value('Corpo libero, Tappetino'),
      focusArea: Value('Retto dell\'addome (parte bassa), Flessori dell\'anca'),
      preparation: Value(
          'Sdraiato supino, gambe tese. Mani sotto i glutei (per supporto lombare) o lungo i fianchi.'),
      execution: Value(
          'Solleva le gambe tese fino alla verticale (90 gradi). Scendi lentamente senza toccare terra con i talloni.'),
      tips: Value(
          'Mantieni la zona lombare premuta a terra per tutto il movimento. Se si inarca, piega leggermente le ginocchia o riduci il ROM.'),
    ),
    ExercisesCompanion(
      name: Value('Russian Twist'),
      targetMuscle: Value('Addominali'),
      equipment: Value('Disco, Manubrio, Kettlebell (opzionale)'),
      focusArea: Value('Obliqui, Retto dell\'addome (rotazione)'),
      preparation: Value(
          'Seduto a terra, ginocchia piegate, talloni a terra (facile) o sollevati (difficile). Busto inclinato indietro (V-sit). Tieni un peso (opzionale) con entrambe le mani.'),
      execution: Value(
          'Ruota il busto e il peso da un lato all\'altro, toccando (o quasi) il pavimento di fianco. Muovi spalle e petto, non solo le braccia.'),
      tips: Value(
          'Mantieni la schiena dritta (non curva). Il movimento deve provenire dalla rotazione del core.'),
    ),
    ExercisesCompanion(
      name: Value('Bicycle Crunch'),
      targetMuscle: Value('Addominali'),
      equipment: Value('Corpo libero, Tappetino'),
      focusArea: Value('Retto dell\'addome, Obliqui (molto completo)'),
      preparation: Value(
          'Supino, mani ai lati della testa. Solleva spalle e gambe da terra.'),
      execution: Value(
          'Porta il gomito destro verso il ginocchio sinistro, mentre estendi la gamba destra. Alterna in modo fluido (\'pedalando\') e controllato. Ruota il busto.'),
      tips: Value(
          'Non tirare il collo. Il movimento deve essere controllato, non una \'corsa\' veloce e senza senso. Concentrati sulla rotazione del torso.'),
    ),
    ExercisesCompanion(
      name: Value('Crunch ai cavi in ginocchio'),
      targetMuscle: Value('Addominali'),
      equipment: Value('Cavo (Ercolina), Corda'),
      focusArea: Value('Retto dell\'addome (con sovraccarico)'),
      preparation: Value(
          'Posiziona la carrucola in alto con la corda. Inginocchiati di fronte, afferra la corda e portala ai lati della testa/collo.'),
      execution: Value(
          'Contrai l\'addome flettendo il busto (\'accartocciati\') verso il pavimento, portando i gomiti verso le ginocchia. Espira forte. Ritorna controllato.'),
      tips: Value(
          'Permette di sovraccaricare l\'addome come un qualsiasi altro muscolo. Mantieni i fianchi fermi; il movimento è una flessione spinale.'),
    ),
    ExercisesCompanion(
      name: Value('Ab Rollout'),
      targetMuscle: Value('Addominali'),
      equipment: Value('Ruota addominale (Ab Wheel)'),
      focusArea: Value('Core (anti-estensione), Retto dell\'addome, Dorsali'),
      preparation: Value('In ginocchio (su un tappetino), afferra la ruota.'),
      execution: Value(
          'Fai rotolare la ruota in avanti lentamente, estendendo il corpo il più possibile mantenendo la schiena neutra (non inarcare!). Ritorna alla posizione iniziale contraendo addome e dorsali.'),
      tips: Value(
          'Esercizio avanzato. Inizia con un ROM breve. Il core deve lavorare per impedire alla schiena di collassare (anti-estensione).'),
    ),
    ExercisesCompanion(
      name: Value('Toes to Bar'),
      targetMuscle: Value('Addominali'),
      equipment: Value('Sbarra per trazioni'),
      focusArea: Value('Retto dell\'addome, Flessori anca (avanzato)'),
      preparation: Value('Appeso alla sbarra.'),
      execution: Value(
          'Contrai l\'addome e solleva le gambe tese fino a toccare la sbarra con le punte dei piedi. Scendi in modo controllato.'),
      tips: Value(
          'Richiede molta forza e flessibilità. Spesso eseguito con \'kipping\' (slancio) nel CrossFit, ma per l\'ipertrofia è meglio la versione controllata (strict).'),
    ),
    ExercisesCompanion(
      name: Value('V-Ups'),
      targetMuscle: Value('Addominali'),
      equipment: Value('Corpo libero, Tappetino'),
      focusArea: Value('Retto dell\'addome (parte alta e bassa)'),
      preparation: Value('Supino, braccia tese oltre la testa, gambe tese.'),
      execution: Value(
          'Contrai l\'addome sollevando contemporaneamente busto e gambe tese, cercando di toccare le punte dei piedi a metà strada (formando una \'V\'). Ritorna controllato.'),
      tips: Value(
          'Esercizio completo e difficile. Se troppo intenso, piega le ginocchia (Tuck-Ups).'),
    ),
    ExercisesCompanion(
      name: Value('Hollow Body Hold'),
      targetMuscle: Value('Addominali'),
      equipment: Value('Corpo libero, Tappetino'),
      focusArea: Value('Core (Trasverso, Retto), Stabilità (base ginnastica)'),
      preparation: Value(
          'Supino. Contrai l\'addome spingendo la zona lombare a terra (fondamentale!). Solleva testa, spalle e gambe tese di pochi cm da terra. Braccia tese oltre la testa o lungo i fianchi.'),
      execution: Value(
          'Mantieni la posizione \'a barchetta\', respirando. La zona lombare NON DEVE staccarsi da terra.'),
      tips: Value(
          'Esercizio isometrico fondamentale per la forza del core. Se la schiena si inarca, piega le ginocchia o alza di più le gambe.'),
    ),
    ExercisesCompanion(
      name: Value('Woodchopper ai cavi'),
      targetMuscle: Value('Addominali'),
      equipment: Value('Cavo (Ercolina), Maniglia o Corda'),
      focusArea: Value('Obliqui, Core (potenza rotazionale)'),
      preparation: Value(
          'Posiziona la carrucola in alto. In piedi di fianco, afferra la maniglia con entrambe le mani.'),
      execution: Value(
          'Tira il cavo diagonalmente verso il basso, ruotando il busto (come se tagliassi legna). Il movimento parte dal core, non dalle braccia. Torna controllato.'),
      tips: Value(
          'Può essere fatto anche dal basso verso l\'alto (\'reverse woodchopper\'). Mantieni i piedi saldi e ruota sul perno del bacino/busto.'),
    ),
    ExercisesCompanion(
      name: Value('Pall of Press ai cavi'),
      targetMuscle: Value('Addominali'),
      equipment: Value('Cavo (Ercolina), Maniglia'),
      focusArea: Value('Obliqui, Core (anti-rotazione)'),
      preparation: Value(
          'Posiziona la carrucola a metà altezza. In piedi di fianco al cavo, afferra la maniglia con entrambe le mani e portala al petto.'),
      execution: Value(
          'Fai un passo laterale per mettere in tensione. Spingi le mani dritte davanti a te, estendendo le braccia. Il cavo cercherà di ruotarti; il tuo addome deve impedirlo. Mantieni 1-3 secondi e torna al petto.'),
      tips: Value(
          'Esercizio isometrico di anti-rotazione. Fondamentale per la stabilità del core.'),
    ),
    ExercisesCompanion(
      name: Value('Sit-up'),
      targetMuscle: Value('Addominali'),
      equipment: Value('Corpo libero, Tappetino (o panca GHD)'),
      focusArea: Value('Retto dell\'addome, Flessori dell\'anca'),
      preparation:
          Value('Supino, ginocchia piegate. (Spesso con piedi bloccati).'),
      execution: Value(
          'Solleva l\'intero busto da terra fino a portarlo in posizione seduta. Scendi controllato.'),
      tips: Value(
          'Coinvolge molto i flessori dell\'anca (psoas). Alcuni lo evitano per stress lombare, preferendo i crunch. Nella versione GHD (Glute Ham Developer) il ROM è estremo.'),
    ),
    ExercisesCompanion(
      name: Value('Dragon Flag'),
      targetMuscle: Value('Addominali'),
      equipment: Value('Panca (o supporto stabile)'),
      focusArea: Value('Core (eccentrica), Retto dell\'addome (avanzatissimo)'),
      preparation: Value(
          'Supino su panca, afferra i bordi dietro la testa. Solleva tutto il corpo (come una candela).'),
      execution: Value(
          'Mantenendo il corpo dritto come una tavola (dalle spalle ai piedi), abbassalo lentamente in modo controllato (fase eccentrica) fino quasi a sfiorare la panca. Risali (se riesci) o ripeti solo l\'eccentrica.'),
      tips: Value(
          'Reso famoso da Bruce Lee. Esercizio di forza pura del core. Inizia solo con la fase eccentrica (negativa).'),
    ),
    ExercisesCompanion(
      name: Value('Flessioni laterali con manubrio'),
      targetMuscle: Value('Addominali'),
      equipment: Value('Manubrio (o Kettlebell)'),
      focusArea: Value('Obliqui, Quadrato dei lombi'),
      preparation: Value(
          'In piedi, tieni un manubrio pesante in una mano. Busto eretto.'),
      execution: Value(
          'Fletti il busto lateralmente sul lato opposto al peso, contraendo l\'obliquo. Risali e fletti leggermente sul lato del peso per allungare.'),
      tips: Value(
          'Lavora principalmente l\'obliquo opposto al peso (per non farti cadere). Non tenere manubri in entrambe le mani (si bilanciano, annullando il lavoro).'),
    ),
    ExercisesCompanion(
      name: Value('Mountain Climbers'),
      targetMuscle: Value('Addominali'),
      equipment: Value('Corpo libero, Tappetino'),
      focusArea: Value('Core (stabilità), Retto addome, Flessori anca, Cardio'),
      preparation:
          Value('Posizione di plank a braccia tese (mani sotto le spalle).'),
      execution: Value(
          'Porta un ginocchio al petto in modo dinamico, poi alterna rapidamente (come se \'corressi\' in posizione plank).'),
      tips: Value(
          'Mantieni il bacino basso e stabile (non deve \'saltare\' su e giù). Ottimo come finisher metabolico per l\'addome.'),
    ),
  ];
}
