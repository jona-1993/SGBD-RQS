using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.Threading.Tasks;

namespace RQS_WPF
{
    [DataContract]
    internal class Review
    {
        [DataMember]
        internal int movie;
        [DataMember]
        internal String login;
        [DataMember]
        internal int cote;
        [DataMember]
        internal String avis;
        [DataMember]
        internal String review_date;

        public Review(int movie, string login, int cote, string avis, string review_date)
        {
            this.movie = movie;
            this.login = login;
            this.cote = cote;
            this.avis = avis;
            this.review_date = review_date;
        }

        public override bool Equals(object obj)
        {
            var review = obj as Review;
            return review != null &&
                   movie == review.movie &&
                   login == review.login &&
                   cote == review.cote &&
                   avis == review.avis &&
                   review_date == review.review_date;
        }

        public override int GetHashCode()
        {
            var hashCode = -1606615611;
            hashCode = hashCode * -1521134295 + movie.GetHashCode();
            hashCode = hashCode * -1521134295 + EqualityComparer<string>.Default.GetHashCode(login);
            hashCode = hashCode * -1521134295 + cote.GetHashCode();
            hashCode = hashCode * -1521134295 + EqualityComparer<string>.Default.GetHashCode(avis);
            hashCode = hashCode * -1521134295 + EqualityComparer<string>.Default.GetHashCode(review_date);
            return hashCode;
        }

        public override string ToString()
        {
            return base.ToString();
        }
    }
}
