import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();

export const deleteGroupsWithUser = functions.firestore
  .document('Users/{userId}')
  .onDelete(async (snap, context) => {
    const userId = context.params.userId;
    const groupsRef = admin.firestore().collection('Groups');
    const snapshot = await groupsRef.where('members', 'array-contains', userId).get();

    const batch = admin.firestore().batch();
    snapshot.forEach(doc => {
      batch.delete(doc.ref);
    });
    await batch.commit();
  });