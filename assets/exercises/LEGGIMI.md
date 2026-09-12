# Figure degli esercizi

Una figura per esercizio, in WebP, con il nome ricavato dal nome
dell'esercizio: minuscolo, senza accenti, e ogni gruppo di caratteri che
non sia una lettera o un numero diventa un trattino.

    Distensioni su panca piana (Bilanciere)
    -> distensioni-su-panca-piana-bilanciere.webp

La regola vive in `lib/features/exercises/domain/exercise_image.dart`
(`exerciseImageSlug`), ed e' l'unico posto in cui e' scritta: i seed non
elencano percorsi, quindi aggiungere una figura e' solo copiare il file
qui dentro.

Chi non ce l'ha mostra il segnaposto tinto sulla regione muscolare, che e'
una resa voluta e non un errore: si puo' riempire il catalogo un
esercizio alla volta.

Misura consigliata: 400x400, sotto i 60 KB. Il catalogo ha 157 esercizi,
quindi a regime questa cartella pesa 5-9 MB di app.
