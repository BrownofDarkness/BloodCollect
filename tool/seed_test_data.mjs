/**
 * Seed des données minimales pour tester les onglets citoyen.
 *
 * Trois collections seulement, celles que l'écran consomme réellement :
 *   - blood_centers     : centres vérifiés (onglets Accueil et Sang)
 *   - blood_stock_lots  : disponibilité par groupe sanguin
 *   - campaigns         : collectes à venir (onglet Donner)
 *
 * Les donneurs ne sont pas créés : `firestore.rules` interdit `list` sur
 * `users`, donc la recherche de donneurs ne peut pas fonctionner tant que
 * cette décision n'est pas tranchée. Créer des comptes Auth ici n'y changerait
 * rien et polluerait le projet.
 *
 * L'identifiant de service contourne les règles, ce qui est nécessaire pour
 * passer les centres en `verified` : l'application s'en verrouille.
 *
 * Usage :
 *   GOOGLE_APPLICATION_CREDENTIALS=/chemin/vers/cle.json node tool/seed_test_data.mjs
 *   ... [--dry-run] [--only=centres,lots,campaigns]
 */

import { applicationDefault, getApps, initializeApp } from 'firebase-admin/app';
import { GeoPoint, getFirestore, Timestamp } from 'firebase-admin/firestore';

const PROJECT_ID = process.env.GCLOUD_PROJECT ?? process.env.FIREBASE_PROJECT_ID;

if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  console.error(
    'GOOGLE_APPLICATION_CREDENTIALS absent.\n' +
      "Génère la clé dans la console Firebase (Paramètres du projet > Comptes de service),\n" +
      'puis : GOOGLE_APPLICATION_CREDENTIALS=/chemin/cle.json node tool/seed_test_data.mjs',
  );
  process.exit(1);
}

if (!getApps().length) {
  // applicationDefault() lit GOOGLE_APPLICATION_CREDENTIALS, qui reste le
  // seul endroit où la clé apparaît : elle n'est jamais lue en dur ici.
  initializeApp({ credential: applicationDefault(), projectId: PROJECT_ID });
}

const db = getFirestore();

const dryRun = process.argv.includes('--dry-run');
const onlyArg = process.argv.find((a) => a.startsWith('--only='));
const only = onlyArg ? onlyArg.slice('--only='.length).split(',') : null;
const wanted = (name) => !only || only.includes(name);

const donorArg = process.argv.find((a) => a.startsWith('--donor='));
const DONOR_UID = donorArg ? donorArg.slice('--donor='.length) : null;

// Les documents portent un ID fixe : relancer le script met à jour au lieu de
// créer des doublons.
const CENTERS = [
  {
    id: 'seed_center_treichville',
    name: 'CNTS Treichville',
    commune: 'Treichville',
    address: 'Rue des Galions, Treichville',
    phone: '+225 27 22 33 44 55',
    agreement: 'AGR-2025-0001',
    lat: 5.3600,
    lng: -3.7900,
  },
  {
    id: 'seed_center_marcory',
    name: 'CHU Marcory — hémocentral',
    commune: 'Marcory',
    address: 'Boulevard Valéry Giscard d’Estaing, Marcory',
    phone: '+225 27 21 66 77 88',
    agreement: 'AGR-2025-0002',
    lat: 5.3450,
    lng: -3.7850,
  },
  {
    id: 'seed_center_cocody',
    name: 'CHU Cocody — hémocentral',
    commune: 'Cocody',
    address: 'Rocciamas, Cocody',
    phone: '+225 27 22 99 00 11',
    agreement: 'AGR-2025-0003',
    lat: 5.3720,
    lng: -3.8465,
  },
];

const BLOOD_TYPES = ['A+', 'O+', 'B+', 'AB+', 'O-'];

// Quantités choisies pour couvrir les trois états agrégés par BloodAvailability :
// > lowStockThreshold (20) disponible, entre unavailableThreshold (5) et 20 en
// tension, <= 5 indisponible.
const LOTS = [
  { center: 'seed_center_treichville', bloodType: 'O+', qty: 45, days: 21 },
  { center: 'seed_center_treichville', bloodType: 'A+', qty: 18, days: 18 },
  { center: 'seed_center_treichville', bloodType: 'B+', qty: 4, days: 12 },
  { center: 'seed_center_marcory', bloodType: 'O+', qty: 62, days: 25 },
  { center: 'seed_center_marcory', bloodType: 'A+', qty: 30, days: 20 },
  { center: 'seed_center_marcory', bloodType: 'AB-', qty: 2, days: 15 },
  { center: 'seed_center_cocody', bloodType: 'O-', qty: 26, days: 19 },
  { center: 'seed_center_cocody', bloodType: 'A+', qty: 8, days: 16 },
];

const now = new Date();
const days = (n) => Timestamp.fromDate(new Date(now.getTime() + n * 86400000));

const written = [];

async function put(path, data) {
  written.push(path);
  if (dryRun) return;
  await db.doc(path).set(data, { merge: true });
}

async function seedCenters() {
  for (const c of CENTERS) {
    await put(`blood_centers/${c.id}`, {
      // Centre fictif : aucun compte ne le possède, donc personne ne peut
      // modifier la fiche ni son statut de vérification.
      userId: 'seed_owner',
      name: c.name,
      address: c.address,
      city: 'Abidjan',
      commune: c.commune,
      location: new GeoPoint(c.lat, c.lng),
      phone: c.phone,
      agreementNumber: c.agreement,
      contactFunction: 'Dr Amadou Koné',
      openingHoursWeekdays: '07h-18h',
      openingHoursSaturday: '08h-13h',
      lowStockThreshold: 20,
      unavailableThreshold: 5,
      // Seul l'Admin SDK peut écrire 'verified' : la règle update verrouille
      // verificationStatus pour l'application.
      verificationStatus: 'verified',
      createdAt: Timestamp.fromDate(now),
      updatedAt: Timestamp.fromDate(now),
    });
  }
  console.log(`  ${CENTERS.length} centres vérifiés`);
}

async function seedLots() {
  for (const [i, lot] of LOTS.entries()) {
    await put(`blood_stock_lots/seed_lot_${i + 1}`, {
      bloodCenterId: lot.center,
      bloodType: lot.bloodType,
      productType: 'whole_blood',
      lotReference: `LOT-${String(i + 1).padStart(3, '0')}`,
      quantity: lot.qty,
      expiryDate: days(lot.days),
      collectionDate: days(-2),
      provenance: 'Don de sang — donneur volontaire',
      internalNote: null,
      status: 'available',
      createdAt: Timestamp.fromDate(now),
      updatedAt: Timestamp.fromDate(now),
    });
  }
  console.log(`  ${LOTS.length} lots de sang`);
}

async function seedCampaigns() {
  const campaigns = [
    {
      id: 'seed_campaign_treichville',
      center: 'seed_center_treichville',
      title: 'Donneuse de sang — Treichville',
      description:
        'Collecte organisée par le CNTS Treichville. Accueil des donneurs de 08h à 16h, sans rendez-vous.',
      commune: 'Treichville',
      communes: ['Treichville', 'Koumassi', 'Marcory'],
      start: 2,
      end: 3,
      types: BLOOD_TYPES,
      units: 120,
    },
    {
      id: 'seed_campaign_marcory',
      center: 'seed_center_marcory',
      title: 'Collecte mobile — Résidentiel Marcory',
      description:
        'Campagne de quartier hosted par le centre de Marcory. Don de sang et analyses de dépistage.',
      commune: 'Marcory',
      communes: ['Marcory', 'Treichville', 'Port-Bouët'],
      start: 6,
      end: 7,
      types: ['O+', 'A+', 'O-'],
      units: 80,
    },
    {
      id: 'seed_campaign_cocody',
      center: 'seed_center_cocody',
      title: 'Collecte universitaire — Cocody',
      description:
        'Avec les étudiants du campus. Prise en charge des dons par le centre.',
      commune: 'Cocody',
      communes: ['Cocody', 'Plateau', 'Yopougon'],
      start: 11,
      end: 12,
      types: ['O+', 'A+', 'B+'],
      units: 150,
    },
  ];

  for (const c of campaigns) {
    await put(`campaigns/${c.id}`, {
      bloodCenterId: c.center,
      title: c.title,
      description: c.description,
      locationName: c.commune,
      commune: c.commune,
      location: new GeoPoint(
        CENTERS.find((x) => x.id === c.center).lat,
        CENTERS.find((x) => x.id === c.center).lng,
      ),
      startDate: days(c.start),
      endDate: days(c.end),
      targetBloodTypes: c.types,
      targetCommunes: c.communes,
      targetUnits: c.units,
      collectedUnits: Math.round(c.units * 0.3),
      notifyDonors: true,
      // `published` : c'est le seul statut que lit un citoyen.
      status: 'published',
      createdAt: Timestamp.fromDate(now),
      updatedAt: Timestamp.fromDate(now),
    });
  }
  console.log(`  ${campaigns.length} collectes publiées`);
}


/// Demandeurs reellement presents dans le projet, releves dans `users`.
///
/// Le donneur cible est passe en argument : une demande de mobilisation n'a de
/// sens que si elle vise le compte connecte, donc le script ne peut pas la
/// creer seul. Les valeurs ci-dessous sont les centres de sante du projet.
const REQUESTERS = [
  {
    id: 'CSCU ANONO',
    requesterId: 'slMGUdMFVzOGVOTwTmMeBki3W673',
    centerName: 'CSCU ANONO',
    commune: 'Cocody',
  },
  {
    id: 'centre de sante 1',
    requesterId: 'acmAnAdjOsazlFp0IHILQ852FH42',
    centerName: 'centre de sante 1',
    commune: 'Mendong',
  },
];

async function seedRequests(donorUid) {
  const settings = [
    { priority: 'elevated', status: 'pending', days: -1 },
    { priority: 'normal', status: 'pending', days: -4 },
    { priority: 'normal', status: 'accepted', days: -12 },
  ];

  for (const [i, r] of REQUESTERS.entries()) {
    const [setting, requester] = [settings[i], REQUESTERS[i]];
    await put(`donor_match_requests/seed_match_${i + 1}`, {
      requesterId: r.requesterId,
      bloodRequestId: null,
      // Cible : le compte du citoyen connecte.
      donorId: donorUid,
      bloodType: BLOOD_TYPES[i % BLOOD_TYPES.length],
      priority: setting.priority,
      status: setting.status,
      shareContact: false,
      message:
        'Don de sang requested pour un patient hospitalise. Presentation ' +
        'au centre indique a la confirmation.',
      internalReference: `SEED-${i + 1}`,
      notifiedAt: Timestamp.fromDate(new Date(now.getTime() + setting.days * 86400000)),
      respondedAt: setting.status === 'pending' ? null : days(setting.days - 2),
      expiresAt: days(6),
      createdAt: Timestamp.fromDate(new Date(now.getTime() + setting.days * 86400000)),
    });
  }
  console.log(`  ${REQUESTERS.length} demandes de mobilisation`);
}


/// Supprime les documents de test.
///
/// Ne passe pas par les reponses du serveur : les batches ont une limite, et
/// les centres seedes sont Explicitement des documents sans proprietaire, donc
/// rien d'autre ne doit etre touche.
async function purge() {
  const PREFIX = 'seed_';
  const COLLECTIONS = [
    'blood_centers',
    'blood_stock_lots',
    'campaigns',
    'donor_match_requests',
  ];

  for (const name of COLLECTIONS) {
    const snapshot = await db.collection(name).get();
    const doomed = snapshot.docs.filter((d) => d.id.startsWith(PREFIX));
    if (!doomed.length) {
      console.log(`  ${name} : rien a supprimer`);
      continue;
    }
    if (dryRun) {
      console.log(`  ${name} : ${doomed.length} document(s) seraient supprimes`);
      continue;
    }

    // Suppression par lot de 400, la limite de l'API.
    for (let i = 0; i < doomed.length; i += 400) {
      const batch = db.batch();
      for (const doc of doomed.slice(i, i + 400)) batch.delete(doc.ref);
      await batch.commit();
    }
    console.log(`  ${name} : ${doomed.length} document(s) supprimes`);
  }
}

// Les sections sont nommées ici plutôt qu'appelées ensequence pour que
// --only=centres fonctionne : le nom dans la commande est celui du libellé.
const SECTIONS = [
  ['centres', seedCenters],
  ['lots', seedLots],
  ['campaigns', seedCampaigns],
  ...(DONOR_UID ? [['demandes', () => seedRequests(DONOR_UID)]] : []),
];

const PURGE = process.argv.includes('--purge');

if (PURGE) {
  console.log(
    dryRun ? 'Simulation (--dry-run), rien n’est supprime :' : 'Suppression des données de test :',
  );
  await purge();
  console.log(
    dryRun
      ? '\nSimulation terminee. Relance sans --dry-run pour supprimer.'
      : '\nDonnees de test supprimees.',
  );
  process.exit(0);
}

if (!DONOR_UID && (!only || only.includes('demandes'))) {
  console.error(
    'Les demandes de mobilisation ciblent un donneur : indique son uid.\n' +
      'Usage : node tool/seed_test_data.mjs --donor=<uid du citoyen connecte>',
  );
  process.exit(1);
}

if (only) {
  const inconnu = only.filter((nom) => !SECTIONS.some(([n]) => n === nom));
  if (inconnu.length) {
    console.error(
      `Section inconnue : ${inconnu.join(', ')}\nSections : ${SECTIONS.map(([n]) => n).join(', ')}`,
    );
    process.exit(1);
  }
}

console.log(dryRun ? 'Simulation (--dry-run), rien n’est écrit :' : 'Écriture des données de test :');
for (const [nom, section] of SECTIONS) {
  if (wanted(nom)) await section();
}

console.log(
  dryRun
    ? `\n${written.length} documents seraient écrits. Relance sans --dry-run.`
    : `\n${written.length} documents écrits.`,
);
process.exit(0);